#!/usr/bin/env bash

# Exit on any error
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting setup..."

# Ensure required tools are installed
if ! command_exists npm; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi
if ! command_exists python; then
    echo "Error: python is not installed. Please install Python first."
    exit 1
fi
if ! command_exists ruby; then
    echo "Error: ruby is not installed. Please install Ruby first."
    exit 1
fi

# Install TypeScript
echo "Setting up TypeScript..."
cd TypeScript
npm install
cd ..

# Install Flow
echo "Setting up Flow..."
cd Flow
npm install
cd ..

# Install Pyright
echo "Setting up Pyright..."
cd Pyright
npm install
cd ..

# Install mypy
echo "Setting up mypy..."
cd mypy
# try to use uv to sync envirionment
if command -v uv 2&>1 >/dev/null; then
    uv sync
else
    # Create virtual environment
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python -m venv venv
    else
        echo "Virtual environment already exists"
    fi
    # Activate the virtual environment
    if [ -f "venv/bin/activate" ]; then
        echo "Activating virtual environment..."
        source venv/bin/activate
    else
        echo "Error: venv/bin/activate not found after creation. Something went wrong."
        exit 1
    fi
    # Install requirements
    if [ -f "requirements.txt" ]; then
        echo "Installing Python dependencies..."
        pip install -r requirements.txt
    else
        echo "Warning: requirements.txt not found in mypy directory. Skipping pip install."
    fi

fi

echo "Setting up Sorbet..."
cd Sorbet
bundle install
cd ..

echo "Setup complete!"
