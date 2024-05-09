@echo off
:: Print starting message
echo [INFO] Starting setup process...

:: Create a Python virtual environment
echo [INFO] Creating virtual environment: venv-imagegen
python -m venv venv-imagegen

:: Activate the virtual environment
echo [INFO] Activating virtual environment
call venv-imagegen\Scripts\activate

:: Print message about installing requirements
echo [INFO] Installing required packages from requirements.txt
pip install -r requirements.txt

:: Print message about running the Python GUI script
echo [INFO] Running configure_and_run_gui.py
python configure_and_run_gui.py

:: Check for errors
if %errorlevel% neq 0 (
    echo [ERROR] Error occurred while running configure_and_run_gui.py
    echo [ERROR] Check the terminal output for details.
    pause
    goto :END
)

:: Deactivate the virtual environment
echo [INFO] Deactivating virtual environment
deactivate

:: Print completion message
echo [INFO] Setup and run process completed.

:END
pause
