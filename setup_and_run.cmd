@echo off
:: Function to install Git if it's not found
:CheckGit
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Git is not installed. Downloading and installing Git...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/Git-2.45.0-64-bit.exe -OutFile Git-Installer.exe"
    if exist Git-Installer.exe (
        start /wait Git-Installer.exe /VERYSILENT /NORESTART
        del Git-Installer.exe
    ) else (
        echo [ERROR] Git installer download failed.
        pause
        exit /b 1
    )
) else (
    echo [INFO] Git is already installed.
)

:: Check for Python installation
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH. Please install Python first.
    pause
    exit /b 1
)

:: Clone the repository
echo [INFO] Cloning the image-worker repository
git clone https://github.com/mrschmiklz/image-worker.git
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone repository. Please ensure Git is installed and the URL is correct.
    pause
    exit /b 1
)

:: Change directory to the image-worker folder
echo [INFO] Changing directory to image-worker
cd image-worker
if %errorlevel% neq 0 (
    echo [ERROR] Directory change failed. Folder 'image-worker' not found.
    pause
    exit /b 1
)

:: Run run_all.cmd
echo [INFO] Running run_all.cmd
call run_all.cmd
