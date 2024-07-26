#!/bin/bash

# Function to install missing package
install_missing_package() {
    local package_name=$1
    echo "Attempting to install missing package: $package_name"
    ./runtime.sh pip install $package_name
    if [ $? -ne 0 ]; then
        echo "Failed to install $package_name. Please install it manually."
        return 1
    fi
    return 0
}

# Function to run Python script with timeout and auto-install
run_with_auto_install() {
    local script_name=$1
    shift
    local timeout=3600  # 1 hour timeout, adjust as needed
    echo "Running $script_name with a $timeout second timeout..."
    timeout $timeout ./runtime.sh python -s $script_name $@ 2>&1 | tee /tmp/${script_name%.py}_output.log &
    local pid=$!
    wait $pid
    local exit_status=$?
    if [ $exit_status -eq 124 ]; then
        echo "Error: $script_name timed out after $timeout seconds."
        return 1
    elif [ $exit_status -ne 0 ]; then
        echo "Error: $script_name exited with status $exit_status. Check /tmp/${script_name%.py}_output.log for details."
        return 1
    fi
    echo "$script_name completed successfully."
    return 0
}

# Function to detect available GPUs
detect_gpus() {
    # Use nvidia-smi to list GPUs and extract their indices
    local gpu_indices=$(nvidia-smi --query-gpu=index --format=csv,noheader,nounits)
    echo $gpu_indices
}

# Function to select GPU
select_gpu() {
    local available_gpus=($(detect_gpus))
    local gpu_count=${#available_gpus[@]}

    if [ $gpu_count -eq 0 ]; then
        echo "No GPUs detected. Exiting."
        exit 1
    elif [ $gpu_count -eq 1 ]; then
        echo "Only one GPU detected. Using GPU ${available_gpus[0]}"
        export CUDA_VISIBLE_DEVICES=${available_gpus[0]}
    else
        echo "Multiple GPUs detected. Select which GPU to use by index:"
        for i in "${!available_gpus[@]}"; do
            echo "$i: GPU ${available_gpus[$i]}"
        done
        read -p "Enter selection (0-$((gpu_count-1))): " selection
        if [[ $selection =~ ^[0-9]+$ ]] && [ $selection -lt $gpu_count ]; then
            export CUDA_VISIBLE_DEVICES=${available_gpus[$selection]}
            echo "Using GPU $CUDA_VISIBLE_DEVICES"
        else
            echo "Invalid selection. Exiting."
            exit 1
        fi
    fi
}

# Set AI_HORDE_URL if not already set
if [ -z "$AI_HORDE_URL" ]; then
    echo "Setting AI_HORDE_URL environment variable"
    export AI_HORDE_URL="https://api.aipowergrid.io/api/"
else
    echo "AI_HORDE_URL is already set to $AI_HORDE_URL"
fi

# Detect and select GPU
select_gpu

# Activate the environment
source ./runtime.sh

# Uninstall hordelib and install updated packages
pip uninstall -y hordelib
pip install horde_sdk~=0.10.0 horde_model_reference~=0.6.3 horde_engine~=2.11.1 horde_safety~=0.2.3 -U

if [ $? -ne 0 ]; then
    echo "Please run update-runtime.sh."
    exit 1
fi

# Change constants in path_consts.py
echo "Modifying path_consts.py to update repository details..."
run_with_auto_install update_path_consts.py

pip check
if [ $? -ne 0 ]; then
    echo "Please run update-runtime.sh."
    exit 1
fi

# Download models
echo "Attempting to download models..."
if run_with_auto_install download_models.py; then
    echo "Model Download OK. Starting worker..."
    run_with_auto_install run_worker.py "$@"
else
    echo "download_models.py exited with error code. Aborting"
    exit 1
fi
