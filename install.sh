#!/bin/bash
# Installation script for md2pdf

set -e

echo "============================================"
echo "md2pdf Installation Script"
echo "============================================"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed."
    echo "Please install Python 3.8 or later and try again."
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Check for pip
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is not installed."
    echo "Please install pip3 and try again."
    exit 1
fi

echo "✓ pip3 found"
echo ""

# Check for required system tools
echo "Checking for required system tools..."
echo ""

MISSING_TOOLS=()

if ! command -v typst &> /dev/null; then
    echo "⚠️  typst is not installed"
    MISSING_TOOLS+=("typst")
else
    echo "✓ typst found: $(typst --version)"
fi

if ! command -v pandoc &> /dev/null; then
    echo "⚠️  pandoc is not installed"
    MISSING_TOOLS+=("pandoc")
else
    echo "✓ pandoc found: $(pandoc --version | head -n1)"
fi

echo ""

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "⚠️  Some required tools are missing: ${MISSING_TOOLS[*]}"
    echo ""
    echo "To install on macOS:"
    echo "  brew install typst pandoc"
    echo ""
    echo "To install on Linux (Debian/Ubuntu):"
    echo "  sudo apt-get install pandoc"
    echo "  cargo install typst-cli"
    echo ""
    read -p "Continue with installation anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

echo "Installing PyInstaller if needed..."
pip3 install pyinstaller

echo ""
echo "Building standalone executable..."
pyinstaller --onefile --name md2pdf --clean md2pdf/cli.py

echo ""
echo "Installing to /usr/local/bin (requires sudo)..."
sudo cp dist/md2pdf /usr/local/bin/md2pdf
sudo chmod +x /usr/local/bin/md2pdf

echo ""
echo "============================================"
echo "✓ Installation complete!"
echo "============================================"
echo ""
echo "md2pdf has been installed to /usr/local/bin"
echo "You can now use 'md2pdf' from anywhere:"
echo "  md2pdf report.md -t templates/report-template.typ"
echo ""
