#!/bin/bash
# Post-install script for Verba
# Installs Python dependencies using system Python

BACKEND_DIR="/usr/lib/Verba/_up_/_up_/backend"

if [ -d "$BACKEND_DIR" ]; then
    echo "Installing Verba Python dependencies..."
    cd "$BACKEND_DIR"
    
    # Install dependencies system-wide or in user site-packages
    python3 -m pip install --user -r requirements.txt 2>/dev/null || \
    python3 -m pip install -r requirements.txt --break-system-packages 2>/dev/null || \
    echo "Warning: Could not install Python dependencies. Run: pip3 install -r $BACKEND_DIR/requirements.txt"
    
    echo "Verba installation complete!"
else
    echo "Warning: Backend directory not found at $BACKEND_DIR"
fi

exit 0
