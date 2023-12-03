#!/bin/bash

# Script Name: <Your-Script-Name>
# Description: This script automates the setup of linting JSON using ESLint with
#  a flat configuration file in a Node.js project.
# It ensures necessary tools and configurations are in place for a project,
# focusing on linting with ESLint and managing Visual Studio Code settings.

# Features:
# - Validates the presence of required tools ('jq' and 'pnpm').
# - Checks for the existence of 'package.json' to confirm if it's running in a
#   Node.js project directory.
# - Installs 'eslint' and 'eslint-plugin-jsonc' if they are not already
#   installed.
# - Configures '.vscode/settings.json' with ESLint options and formatter
#   settings.
# - Dynamically updates the 'eslint.validate' array and other configuration
#   objects in VS Code settings without overwriting existing settings.

# Functions:
# - is_package_installed: Checks if a specified npm package is installed in the
#   project.
# - check_and_install_package: Installs a given npm package if not already
#   installed.
# - Configurations are applied in a non-destructive manner, preserving existing
#   settings in 'settings.json'.

# Error Handling:
# - Reports missing tools or 'package.json'.
# - Exits if any prerequisite is not met, ensuring no partial configuration.

# Configurations Applied:
# - ESLint options and experimental settings are merged with existing settings.
# - Disables default JSON validation in VS Code.
# - Sets ESLint as the default formatter for JSON-related files.
# - Enables ESLint formatting and auto-fix on save actions.
# - Adds or updates 'eslint.validate' array and other object configurations,
#   ensuring no existing configurations are removed.

# Usage:
# - Place the script in the root directory of your Node.js project.
# - Ensure 'jq' and 'pnpm' are installed.
# - Run the script with Bash. It will perform checks, installations, and
#   configurations automatically.

# Requirements:
# - Bash environment.
# - 'pnpm' package manager.
# - 'jq' for JSON processing.

# Note:
# - The script modifies the '.vscode/settings.json' file. Backup existing
#   settings before running.
# - The script expects to be run in the root directory of a Node.js project
#   where 'package.json' is located.

# Replace <Your-Script-Name> with the actual name of your script.

# Begin script implementation
# ... rest of your script ...



# Function to check if a package is installed using jq to parse pnpm list output
is_package_installed() {
    package_name="$1"
    # Check if the package is installed and listed in package.json as a dev dependency
    if pnpm list --depth 0 --dev --json | jq -e --arg pkg "$package_name" '.[0].devDependencies[$pkg] != null' &> /dev/null; then
        if jq -e --arg pkg "$package_name" '.devDependencies[$pkg] != null' "package.json" &> /dev/null; then
            return 0 # Package is installed and listed as a dev dependency
        fi
    fi
    return 1 # Package is not installed or not listed as a dev dependency
}

# Function to check and install a package
check_and_install_package() {
    if ! is_package_installed "$1"; then
        echo "Installing $1..."
        pnpm add -D "$1"
    fi
}

# Array to store error messages
errors=()

# Check for jq
if ! command -v jq &> /dev/null; then
  errors+=("jq is not installed. Please install it (https://jqlang.github.io/jq/) and try again.")
fi

# Check for pnpm
if ! command -v pnpm &> /dev/null; then
  errors+=("pnpm is not installed. Please install it (https://pnpm.io/) and try again.")
fi


# Check for package.json
if [ ! -f "package.json" ]; then
  errors+=("package.json not found. Please run 'pnpm init' and try again.")
fi

# If errors array has one or more elements, print them and exit
if [ ${#errors[@]} -ne 0 ]; then
  for err in "${errors[@]}"; do
    echo "$err"
  done
  exit 1
fi

# Desired ESLint script
ESLINT_SCRIPT="ESLINT_USE_FLAT_CONFIG=true npx eslint --config eslint.config.mjs ."

# Check and update "scripts" in package.json
if ! jq -e '.scripts' "package.json" &>/dev/null; then
    # If scripts object does not exist, add it
    echo "Adding scripts to package.json..."
    jq --arg es "$ESLINT_SCRIPT" '.scripts = {"eslint": $es}' "package.json" > "package.tmp.json" && mv "package.tmp.json" "package.json"
else
    # If scripts object exists, check eslint script
    EXISTING_SCRIPT=$(jq -r '.scripts.eslint // empty' "package.json")
    if [ -n "$EXISTING_SCRIPT" ] && [ "$EXISTING_SCRIPT" != "$ESLINT_SCRIPT" ]; then
        echo "Error: 'eslint' script in package.json differs from expected."
        echo "Expected script: $ESLINT_SCRIPT"
        echo "Found script   : $EXISTING_SCRIPT"
        echo "Please resolve this conflict manually."
        exit 1
    elif [ -z "$EXISTING_SCRIPT" ]; then
        # If eslint script doesn't exist, add it
        jq --arg es "$ESLINT_SCRIPT" '.scripts.eslint = $es' "package.json" > "package.tmp.json" && mv "package.tmp.json" "package.json"
    fi
fi


# Check and install eslint and eslint-plugin-jsonc
check_and_install_package "eslint"
check_and_install_package "eslint-plugin-jsonc"

# Create .vscode directory if it doesn't exist
if [ ! -d ".vscode" ]; then
    mkdir .vscode
fi

# Check and update settings.json to ensure it contains a valid JSON object
if [ ! -f ".vscode/settings.json" ] || [ ! -s ".vscode/settings.json" ]; then
    echo "{}" > ".vscode/settings.json"
else
    # Check if the file contains a valid JSON object
    if ! jq -e . ".vscode/settings.json" &>/dev/null; then
        echo "The file '.vscode/settings.json' file is invalid. Please fix any issues in the json file and try again."
        exit 1
    fi
fi

# Configuration options to add/update
CONFIGURATIONS=(
    '.["eslint.options"] += {"overrideConfigFile": "eslint.config.mjs"}'
    '.["eslint.experimental.useFlatConfig"] = true'
    '.["json.validate.enable"] = false'
    '."[json]" += {"editor.defaultFormatter": "dbaeumer.vscode-eslint"}'
    '."[jsonc]" += {"editor.defaultFormatter": "dbaeumer.vscode-eslint"}'
    '."[json5]" += {"editor.defaultFormatter": "dbaeumer.vscode-eslint"}'
    '.["eslint.format.enable"] = true'
    '.["editor.codeActionsOnSave"] += {"source.fixAll.eslint": true}'
)

# Apply configurations to settings.json
for config in "${CONFIGURATIONS[@]}"; do
    jq "$config" ".vscode/settings.json" > ".vscode/temp_settings.json" && mv ".vscode/temp_settings.json" ".vscode/settings.json"
done

# Special handling for eslint.validate array
# Initialize eslint.validate as an empty array if it doesn't exist or is empty
if ! jq -e '.["eslint.validate"] | select(length > 0)' ".vscode/settings.json" &>/dev/null; then
    jq '.["eslint.validate"] = []' ".vscode/settings.json" > ".vscode/temp_settings.json" && mv ".vscode/temp_settings.json" ".vscode/settings.json"
fi

ESLINT_VALIDATE_OPTIONS=("json" "jsonc")

# Add each option to eslint.validate if not already present
for option in "${ESLINT_VALIDATE_OPTIONS[@]}"; do
    if ! jq -e --arg opt "$option" '.["eslint.validate"] | index($opt)' ".vscode/settings.json" &>/dev/null; then
        jq --arg opt "$option" '.["eslint.validate"] += [$opt]' ".vscode/settings.json" > ".vscode/temp_settings.json" && mv ".vscode/temp_settings.json" ".vscode/settings.json"
    fi
done


# URL of the eslint.config.mjs file
ESLINT_CONFIG_URL="https://raw.githubusercontent.com/erichosick/eslint-json-flat-config-template/main/templates/eslint.config.mjs"

# Check if eslint.config.mjs exists in the root directory
if [ ! -f "eslint.config.mjs" ]; then
    echo "Downloading eslint.config.mjs from $ESLINT_CONFIG_URL..."
    curl -o "eslint.config.mjs" "$ESLINT_CONFIG_URL"
else
    # Compare the contents of the existing file with the one from the URL
    if ! curl -s "$ESLINT_CONFIG_URL" | cmp -s "eslint.config.mjs" -; then
        echo "An eslint.config.mjs file already exists, and differs from the online template. Please manually merge the configuration from the online template into your existing config file."
    fi
fi