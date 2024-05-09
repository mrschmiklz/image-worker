import tkinter as tk
from tkinter import ttk, messagebox
import requests
import yaml
import subprocess
import os
import torch

# Load existing bridgeData.yaml if it exists
config_path = "bridgeData.yaml"
default_data = {
    "api_key": "Please set your API key - https://api.aipowergrid.io/register",
    "dreamer_name": "",
    "gpu": 0,
    "max_threads": 1,
    "queue_size": 1,
    "max_power": 50,
    "bridge_types": ["dreamer", "interrogation", "post-process"]
}

if os.path.exists(config_path):
    with open(config_path, "r") as file:
        try:
            config_data = yaml.safe_load(file)
        except yaml.YAMLError:
            config_data = {}
else:
    config_data = {}

# Merge with defaults to ensure all keys are present
for key, value in default_data.items():
    if key not in config_data:
        config_data[key] = value

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

# Save updated configuration data to YAML
def save_config():
    config_data["api_key"] = api_key_var.get()
    config_data["dreamer_name"] = dreamer_name_var.get()
    config_data["gpu"] = gpu_combobox.current()
    config_data["max_threads"] = max_threads_var.get()
    config_data["queue_size"] = queue_size_var.get()
    config_data["max_power"] = max_power_combobox.get()
    config_data["bridge_types"] = [bridge_types_listbox.get(idx) for idx in bridge_types_listbox.curselection()]

    with open(config_path, "w") as file:
        yaml.safe_dump(config_data, file)

# Check for available GPUs
def detect_gpus():
    if torch.cuda.is_available():
        return [f"GPU{i}: {torch.cuda.get_device_name(i)}" for i in range(torch.cuda.device_count())]
    else:
        return ["No GPU Found"]

# Advanced Options popup
def show_advanced_options():
    advanced_window = tk.Toplevel(root)
    advanced_window.title("Advanced Options")
    advanced_window.geometry("300x400")

    tk.Label(advanced_window, text="Max Threads:").pack(anchor="w")
    tk.Entry(advanced_window, textvariable=max_threads_var).pack(fill="x", padx=10)

    tk.Label(advanced_window, text="Queue Size:").pack(anchor="w")
    tk.Entry(advanced_window, textvariable=queue_size_var).pack(fill="x", padx=10)

    tk.Label(advanced_window, text="Bridge Types:").pack(anchor="w")
    bridge_types_listbox.pack(fill="both", padx=10, pady=5)
    for item in default_data["bridge_types"]:
        bridge_types_listbox.insert("end", item)

    save_button = tk.Button(advanced_window, text="Save", command=lambda: [save_config(), advanced_window.destroy()])
    save_button.pack(pady=10)

# Start the bridge process
def start_bridge():
    if not verify_api_key(api_key_var.get()):
        messagebox.showerror("Error", "Invalid API Key")
        return
    save_config()
    subprocess.run(["horde-bridge.cmd"])
    root.destroy()

# Setup GUI
root = tk.Tk()
root.title("Horde Bridge Configuration")
root.geometry("400x350")

api_key_var = tk.StringVar(value=config_data["api_key"])
dreamer_name_var = tk.StringVar(value=config_data["dreamer_name"])
gpu_list = detect_gpus()
gpu_index = config_data.get("gpu", 0)

# Make sure the index is valid
if gpu_index >= len(gpu_list):
    gpu_index = 0

max_threads_var = tk.IntVar(value=config_data.get("max_threads", 1))
queue_size_var = tk.IntVar(value=config_data.get("queue_size", 1))

max_power_options = [8, 18, 32, 50]
max_power_var = config_data.get("max_power", 50)

tk.Label(root, text="API Key:").pack(anchor="w", padx=10)
tk.Entry(root, textvariable=api_key_var).pack(fill="x", padx=10)

tk.Label(root, text="Dreamer Name:").pack(anchor="w", padx=10)
tk.Entry(root, textvariable=dreamer_name_var).pack(fill="x", padx=10)

tk.Label(root, text="GPU:").pack(anchor="w", padx=10)
gpu_combobox = ttk.Combobox(root, values=gpu_list)
gpu_combobox.current(gpu_index)
gpu_combobox.pack(fill="x", padx=10)

tk.Label(root, text="Max Power:").pack(anchor="w", padx=10)
max_power_combobox = ttk.Combobox(root, values=max_power_options)
max_power_combobox.set(max_power_var)
max_power_combobox.pack(fill="x", padx=10)

bridge_types_listbox = tk.Listbox(selectmode="multiple")

advanced_button = tk.Button(root, text="Advanced Options", command=show_advanced_options)
advanced_button.pack(pady=10)

start_button = tk.Button(root, text="Start Bridge", command=start_bridge)
start_button.pack(pady=10)

root.mainloop()
