#!/bin/bash
# Build script for md2pdf standalone executable

set -e

echo "============================================"
echo "Building md2pdf standalone executable"
echo "============================================"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed."
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Install PyInstaller if needed
echo "Ensuring PyInstaller is installed..."
pip3 install pyinstaller

echo ""
echo "Building executable..."
pyinstaller --onefile --name md2pdf --clean md2pdf/cli.py

echo ""
echo "============================================"
echo "✓ Build complete!"
echo "============================================"
echo ""
echo "Executable created at: dist/md2pdf"
echo ""
echo "To install system-wide, run:"
echo "  sudo cp dist/md2pdf /usr/local/bin/"
echo "  sudo chmod +x /usr/local/bin/md2pdf"
echo ""
