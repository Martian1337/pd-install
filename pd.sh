#!/bin/bash

# Install go
install_go() {
    sudo apt update
    sudo apt install -y golang-go
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed."
    read -rp "Do you want to install Go now? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        install_go
    else
        echo "Go installation aborted. Exiting."
        exit 1
    fi
fi

# Add $HOME/go/bin to the PATH variable if not already added
if ! grep -qF "$HOME/go/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$PATH:$HOME/go/bin"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi

# Define a mapping of package names to import paths
declare -A tool_map=(
    ["interactsh"]="github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    ["alterx"]="github.com/projectdiscovery/alterx/cmd/alterx@latest"
    ["chaos"]="github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    ["cloudlist"]="github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest"
    ["cvemap"]="github.com/projectdiscovery/cvemap/cmd/cvemap@latest"
    ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
    ["naabu"]="github.com/projectdiscovery/naabu/cmd/naabu@latest"
    ["notify"]="github.com/projectdiscovery/notify/cmd/notify@latest"
    ["nuclei"]="github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    ["pdtm"]="github.com/projectdiscovery/pdtm/cmd/pdtm@latest"
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    ["uncover"]="github.com/projectdiscovery/uncover/cmd/uncover@latest"
)

# Function to prompt user for tool installation
prompt_user() {
    while true; do
        echo "Select packages to install (comma-separated) or type 'all' for installing all packages:"
        echo "Available packages: ${!package_map[*]}"
        read -rp "> " input

        # Install selected tools
        selected_tools=()
        if [[ "$input" == "all" ]]; then
            selected_tools=("${tool_map[@]}")
        else
            IFS=',' read -ra selected <<< "$input"
            for package in "${selected[@]}"; do
                package=$(echo "$package" | xargs)  # Trim whitespace
                if [[ -n "${tool_map[$package]}" ]]; then
                    selected_packages+=("${tool_map[$ptool]}")
                else
                    echo "Warning: Invalid package '$tool' will be ignored."
                fi
            done
        fi

        # Check validity
        if [[ ${#selected_tools[@]} -gt 0 ]]; then
            for package in "${selected_tools[@]}"; do
                tool_name=$(basename "$tool" | cut -d '@' -f 1)
                if command -v "$tool_name" &> /dev/null; then
                    echo "$tool_name is already installed."
                else
                    go install "$tool"
                fi
            done
            break
        else
            echo "No valid packages selected. Please try again."
        fi
    done
}

# Initial prompt for tool installation
prompt_user

# Prompt user for additional tool installation if any tools were already installed
while true; do
    read -rp "Do you want to install more tools? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        prompt_user
    elif [[ $choice =~ ^[Nn]$ ]]; then
        echo "Exiting."
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done
