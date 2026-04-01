#!/bin/bash
# Shipwright Setup — installs and verifies the product-agent build engine
# Idempotent: safe to run multiple times. Exits 0 on success, 1 on failure.

set -e

MIN_VERSION=12
LOCAL_SOURCE="$HOME/Projects/product-agent"

# Colors (if terminal supports them)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' NC=''
fi

info()  { echo -e "${GREEN}[Shipwright]${NC} $1"; }
warn()  { echo -e "${YELLOW}[Shipwright]${NC} $1"; }
error() { echo -e "${RED}[Shipwright]${NC} $1"; }

# --- Step 1: Check prerequisites ---

if ! command -v python3 &>/dev/null; then
    error "python3 is required but not found."
    echo "  Install it with: brew install python3 (Mac) or sudo apt install python3 (Linux)"
    exit 1
fi

if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
    error "pip is required but not found."
    echo "  Install it with: python3 -m ensurepip --upgrade"
    exit 1
fi

# Use python3 -m pip for reliability
PIP="python3 -m pip"

# --- Step 2: Check if already installed ---

if command -v product-agent &>/dev/null; then
    INSTALLED_VERSION=$(product-agent --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "0")
    if [ "$INSTALLED_VERSION" -ge "$MIN_VERSION" ] 2>/dev/null; then
        info "product-agent v${INSTALLED_VERSION} is already installed and up to date."
        exit 0
    else
        warn "product-agent is installed but version $INSTALLED_VERSION is below minimum ($MIN_VERSION). Upgrading..."
    fi
fi

# --- Step 3: Install (try sources in order) ---

info "Installing product-agent build engine..."

# Try 1: PyPI (preferred — clean install)
if $PIP install product-agent 2>/dev/null; then
    info "Installed from PyPI."
elif [ -d "$LOCAL_SOURCE" ] && $PIP install -e "$LOCAL_SOURCE" 2>/dev/null; then
    # Try 2: Local development source (for contributors)
    info "Installed from local source ($LOCAL_SOURCE)."
else
    # All methods failed
    error "Could not install product-agent automatically."
    echo ""
    echo "  Please install it manually:"
    echo ""
    echo "    pip install product-agent"
    echo ""
    echo "  If the package is not yet on PyPI, ask for the install link or"
    echo "  clone the source repository and run: pip install -e /path/to/product-agent"
    echo ""
    exit 1
fi

# --- Step 4: Verify installation ---

if ! command -v product-agent &>/dev/null; then
    error "Installation appeared to succeed, but 'product-agent' command not found."
    echo "  This usually means pip installed to a directory not on your PATH."
    echo "  Try: python3 -m product_agent --help"
    echo "  Or add pip's bin directory to your PATH."
    exit 1
fi

FINAL_VERSION=$(product-agent --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "unknown")
info "product-agent v${FINAL_VERSION} is ready."
exit 0
