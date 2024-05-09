@echo off
:: Run cuda_check.cmd
echo [INFO] Running CUDA Check
call cuda_check.cmd
if %errorlevel% neq 0 (
    echo [ERROR] CUDA Check failed. Please fix the issue before proceeding.
    pause
    exit /b 1
)

:: Run setup_and_run.cmd
echo [INFO] Running Setup and Run
call setup_and_run.cmd
