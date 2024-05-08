import requests
import shutil
import yaml
import subprocess
import os

# Path to the bridgeData template
template_path = "bridgeData_template.yaml"
config_path = "bridgeData.yaml"

# Copy the bridgeData_template.yaml to bridgeData.yaml
shutil.copyfile(template_path, config_path)

# Load the template data
with open(config_path, "r") as file:
    config_data = yaml.safe_load(file)

# Function to verify the API key
def verify_api_key(api_key):
    headers = {
        "apikey": api_key,
        "Client-Agent": "horde-bridge:1.0"
    }
    response = requests.get("https://api.aipowergrid.io/api/v2/find_user", headers=headers)

    if response.status_code == 200:
        user_info = response.json()
        username = user_info.get("username", "Unknown")
        print(f"User '{username}' found on the grid.")
        return True
    else:
        print(f"Error: Response status is {response.status_code}")
        print(response.json())
        return False

# Function to safely prompt for API key
def get_api_key():
    while True:
        api_key = input("Enter your API key: ").strip()
        print(f"Entered API key: {api_key}")
        if verify_api_key(api_key):
            print("API key verified successfully.")
            return api_key
        else:
            print("Invalid API key. Please set your API key - https://api.aipowergrid.io/register")
            print("Please try again.")

# Prompt for the API key until a valid one is entered
api_key = get_api_key()

# Prompt for the worker name
dreamer_name = input("Enter your Dreamer worker name: ").strip()

# Update the config data with the verified API key and worker name
config_data["api_key"] = api_key
config_data["dreamer_name"] = dreamer_name

# Write the updated data back to bridgeData.yaml
with open(config_path, "w") as file:
    yaml.safe_dump(config_data, file)

# Run the horde-bridge.cmd script
subprocess.run(["horde-bridge.cmd"])
