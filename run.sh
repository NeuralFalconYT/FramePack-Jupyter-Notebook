#!/bin/bash

# Set working directory
root_path="$(pwd)"
echo "📁 Using root path: $root_path"

# Clone FramePack if it doesn't exist
if [ ! -d "$root_path/FramePack" ]; then
    echo "📥 Cloning FramePack..."
    git clone https://github.com/lllyasviel/FramePack.git
fi

# Enter the FramePack folder
cd "$root_path/FramePack"

# Check current PyTorch + CUDA version
cuda_version_ok=false

if python -c "import torch; print(torch.version.cuda)" &> /dev/null; then
    current_cuda=$(python -c "import torch; print(torch.version.cuda)")
    echo "🎯 Detected CUDA version in PyTorch: $current_cuda"

    if [[ "$current_cuda" == "12.6" ]]; then
        cuda_version_ok=true
        echo "✅ CUDA 12.6 is already installed with PyTorch."
    else
        echo "⚠ PyTorch is using CUDA $current_cuda instead of 12.6. Reinstalling..."
    fi
else
    echo "⚠ PyTorch not installed. Installing with CUDA 12.6..."
fi

# Uninstall old PyTorch if necessary and install correct version
if [ "$cuda_version_ok" = false ]; then
    pip uninstall -y torch torchvision torchaudio
    pip install --upgrade --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
fi

# Install other Python dependencies
echo "📦 Installing other Python dependencies..."
pip install -r requirements.txt

# Optional: install attention modules
# pip install xformers
# pip install flash-attn --no-build-isolation
echo "🧠 Installing SageAttention..."
pip install sageattention==1.0.6

# Pause for user to review logs
echo ""
read -p "📋 Press Enter to clear the screen and select a demo..."

# Clear terminal output
clear

# Prompt user to select which demo to run
echo "🔧 Choose which demo to run:"
echo "1. FramePack"
echo "2. FramePack-F1"
read -p "Enter 1 or 2: " choice

echo "🚀 Launching Gradio demo..."
if [ "$choice" == "1" ]; then
    python demo_gradio.py --share
elif [ "$choice" == "2" ]; then
    python demo_gradio_f1.py --share
else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi
