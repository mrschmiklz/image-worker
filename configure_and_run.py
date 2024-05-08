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

# Prompt for API key and worker name
api_key = input("Enter your API key: ")
dreamer_name = input("Enter your Dreamer worker name: ")

# Verify the API key
headers = {
    "apikey": api_key,
    "Client-Agent": "horde-bridge:1.0"
}

response = requests.get("https://api.aipowergrid.io/api/", headers=headers)

if response.status_code == 200:
    print("API key verified successfully.")
    config_data["api_key"] = api_key
    config_data["dreamer_name"] = dreamer_name
else:
    print("Invalid API key. Please set your API key - https://api.aipowergrid.io/register")
    exit(1)

# Write the updated data back to bridgeData.yaml
with open(config_path, "w") as file:
    yaml.safe_dump(config_data, file)

# Run the horde-bridge.cmd script
subprocess.run(["horde-bridge.cmd"])