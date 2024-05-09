@echo off
:: Check for CUDA 12.1
set "CUDA_PATH_V12_1=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1"

if exist "%CUDA_PATH_V12_1%" (
    echo [INFO] CUDA 12.1 is already installed.
) else (
    echo [INFO] CUDA 12.1 is not installed. Downloading and installing...
    :: Corrected download link for CUDA 12.1 installer
    powershell -Command "Invoke-WebRequest -Uri https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_531.14_windows.exe -OutFile cuda_12.1.0_installer.exe"
    
    :: Install CUDA 12.1 (silent mode)
    start /wait cuda_12.1.0_installer.exe -s
    if %errorlevel% neq 0 (
        echo [ERROR] CUDA 12.1 installation failed.
        exit /b 1
    )
    echo [INFO] CUDA 12.1 installed successfully.
)

:: Set environment variables for CUDA 12.1
setx CUDA_PATH "%CUDA_PATH_V12_1%"
setx PATH "%CUDA_PATH%;%CUDA_PATH%\bin;%CUDA_PATH%\libnvvp;%PATH%"

:: Activate the virtual environment
echo [INFO] Activating virtual environment
call venv-imagegen\Scripts\activate

:: Install PyTorch and additional packages
echo [INFO] Installing PyTorch with CUDA 12.1 support
pip install torch==2.1.2+cu121 torchvision==0.16.2+cu121 torchaudio==2.1.2+cu121 --index-url https://download.pytorch.org/whl/test/cu121

echo [INFO] Installing other Python packages from requirements.txt
pip install -r requirements.txt

:: Completion message
echo [INFO] Setup and package installation completed.
pause
