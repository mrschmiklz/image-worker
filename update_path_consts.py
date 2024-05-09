import fileinput
import sys
import os
import site

# Find the location of the site-packages folder
site_packages_dirs = site.getsitepackages()

# Locate `horde_model_reference` directory
horde_model_ref_dir = None
for site_dir in site_packages_dirs:
    potential_path = os.path.join(site_dir, 'horde_model_reference')
    if os.path.isdir(potential_path):
        horde_model_ref_dir = potential_path
        break

# Check if `horde_model_reference` was found
if horde_model_ref_dir is None:
    print("[ERROR] `horde_model_reference` package not found in the current environment.")
    sys.exit(1)

# Construct the path to the `path_consts.py` file
file_path = os.path.join(horde_model_ref_dir, 'path_consts.py')

# Ensure the file exists
if not os.path.exists(file_path):
    print(f"[ERROR] `path_consts.py` file not found at `{file_path}`")
    sys.exit(1)

# Define patterns to replace
owner_pattern = 'GITHUB_REPO_OWNER = "Haidra-Org"'
new_owner = 'GITHUB_REPO_OWNER = "AIPowergrid"'
repo_pattern = 'GITHUB_REPO_NAME = "AI-Horde-image-model-reference"'
new_repo = 'GITHUB_REPO_NAME = "grid-image-model-reference"'

# Update the file
with fileinput.FileInput(file_path, inplace=True, backup='.bak') as file:
    for line in file:
        line = line.replace(owner_pattern, new_owner)
        line = line.replace(repo_pattern, new_repo)
        sys.stdout.write(line)

print("[INFO] `path_consts.py` successfully updated.")
