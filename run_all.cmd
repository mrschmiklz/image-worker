@echo off
:: Run CUDA Check
echo [INFO] Running CUDA Check
call cuda_check.cmd
if %errorlevel% neq 0 (
    echo [ERROR] CUDA Check failed. Please fix the issue before proceeding.
    pause
    exit /b 1
)

:: Create or Activate Virtual Environment
echo [INFO] Checking/Creating virtual environment: venv-imagegen
if not exist "venv-imagegen\Scripts\activate" (
    echo [INFO] Creating virtual environment
    python -m venv venv-imagegen
)

:: Activate the virtual environment
echo [INFO] Activating virtual environment
call venv-imagegen\Scripts\activate
if %errorlevel% neq 0 (
    echo [ERROR] Virtual environment activation failed.
    pause
    exit /b 1
)

:: Upgrade pip and Install PyTorch with CUDA 12.1 support
echo [INFO] Installing PyTorch with CUDA 12.1 support
pip install torch==2.1.2+cu121 torchvision==0.16.2+cu121 torchaudio==2.1.2+cu121 -f https://download.pytorch.org/whl/test/cu121

:: Install additional Python packages
echo [INFO] Installing other Python packages from requirements.txt
pip install -r requirements.txt

:: Deactivate the virtual environment
echo [INFO] Deactivating virtual environment
call venv-imagegen\Scripts\deactivate.bat 2>nul || (
    echo [INFO] Deactivation script not found. Ignoring...
)

:: Print completion message
echo [INFO] Setup and package installation completed.

pause
