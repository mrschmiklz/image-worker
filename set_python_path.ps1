# Define Python paths
$pythonDir = "$env:LOCALAPPDATA\Programs\Python\Python310"
$pythonScripts = "$pythonDir\Scripts"

# Check if Python directory exists
if (-Not (Test-Path $pythonDir)) {
    Write-Output "[ERROR] Python directory '$pythonDir' not found. Please install Python first."
    pause
    exit 1
}

# Retrieve the current user path
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")

# Check if Python directory is already in the PATH
if ($userPath -notlike "*$pythonDir*") {
    Write-Output "[INFO] Adding Python directory to User PATH"
    $newPath = "$userPath;$pythonDir;$pythonScripts"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
} else {
    Write-Output "[INFO] Python directory already in User PATH"
}

# Verify if the paths were added
Write-Output "[INFO] Verifying if Python was added to PATH"
if ((Get-Command python -ErrorAction SilentlyContinue) -eq $null) {
    Write-Output "[ERROR] Python not found in PATH."
} else {
    Write-Output "[INFO] Python successfully added to PATH."
}

pause