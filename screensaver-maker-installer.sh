#!/bin/bash
# Screensaver Maker - Self-Installing Package
# Run this script to install and set up everything

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="screensaver-maker"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/screensaver-maker.desktop"
FONT_DIR="$HOME/.local/share/figlet"
FONT_FILE="$FONT_DIR/Delta-Corps-Priest-1.flf"
FONT_URL="https://raw.githubusercontent.com/xero/figlet-fonts/master/Delta%20Corps%20Priest%201.flf"

echo "Installing Screensaver Maker..."

# Create install directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$FONT_DIR"
mkdir -p "$HOME/.local/share/applications"

# Check dependencies
MISSING_DEPS=""
command -v figlet &>/dev/null || MISSING_DEPS="$MISSING_DEPS figlet"
command -v zenity &>/dev/null || MISSING_DEPS="$MISSING_DEPS zenity"
command -v python3 &>/dev/null || MISSING_DEPS="$MISSING_DEPS python3"
command -v curl &>/dev/null || MISSING_DEPS="$MISSING_DEPS curl"

if [ -n "$MISSING_DEPS" ]; then
    echo "Missing dependencies:$MISSING_DEPS"
    echo "Installing missing dependencies..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm $MISSING_DEPS
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y $MISSING_DEPS
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y $MISSING_DEPS
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y $MISSING_DEPS
    else
        echo "Could not detect package manager. Please install manually:$MISSING_DEPS"
        exit 1
    fi

    # Verify installation succeeded
    STILL_MISSING=""
    command -v figlet &>/dev/null || STILL_MISSING="$STILL_MISSING figlet"
    command -v zenity &>/dev/null || STILL_MISSING="$STILL_MISSING zenity"
    command -v python3 &>/dev/null || STILL_MISSING="$STILL_MISSING python3"
    command -v curl &>/dev/null || STILL_MISSING="$STILL_MISSING curl"

    if [ -n "$STILL_MISSING" ]; then
        echo "Failed to install:$STILL_MISSING"
        exit 1
    fi
    echo "Dependencies installed successfully!"
fi

# Download font if not present
if [ ! -f "$FONT_FILE" ]; then
    echo "Downloading Delta Corps Priest 1 font..."
    curl -sL "$FONT_URL" -o "$FONT_FILE"
    if [ ! -f "$FONT_FILE" ]; then
        echo "Failed to download font."
        exit 1
    fi
fi

# Patch the font
echo "Patching font with additional characters..."
python3 << 'PATCH_SCRIPT'
import os
FONT_FILE = os.path.expanduser("~/.local/share/figlet/Delta-Corps-Priest-1.flf")
CHARS = {
    33: ["  ███ $@","  ███ $@","  ███ $@","  ███ $@","  ███ $@","      $@","  ███ $@","  █▀  $@","      @@"],
    34: [" ██ ██ $@"," ██ ██ $@"," █▀ █▀ $@","       $@","       $@","       $@","       $@","       $@","        @@"],
    35: ["  ██  ██  $@","  ██  ██  $@","██████████$@","  ██  ██  $@","██████████$@","  ██  ██  $@","  ██  ██  $@","          $@","           @@"],
    36: ["  ▄█▄  $@"," █████ $@","██▄█   $@"," ▀███▄ $@","   █▀██$@"," █████ $@","  ▀█▀  $@","       $@","        @@"],
    37: ["██▄  ▄██$@","▀█▌ ▐█▀ $@","   ▐█▌  $@","  ▄█▀   $@"," ▄█▀    $@","▐█▌     $@","█▀  ▄██ $@","   ▀▀▀  $@","         @@"],
    38: ["  ▄███▄   $@"," ███ ███  $@","  ▀███▀   $@"," ▄███▄    $@","███ ███ ██$@","███  ▀███ $@"," ▀███▄▄██ $@","   ▀▀▀ ▀▀ $@","           @@"],
    39: ["  ██ $@","  ██ $@","  █▀ $@","     $@","     $@","     $@","     $@","     $@","      @@"],
    40: ["   ▄██$@","  ██▀ $@"," ██   $@","██    $@","██    $@"," ██   $@","  ██▄ $@","   ▀██$@","      @@"],
    41: ["██▄   $@"," ▀██  $@","   ██ $@","    ██$@","    ██$@","   ██ $@"," ▄██  $@","██▀   $@","      @@"],
    42: ["       $@"," █   █ $@","  █ █  $@","███████$@","  █ █  $@"," █   █ $@","       $@","       $@","        @@"],
    43: ["       $@","   █   $@","   █   $@"," █████ $@","   █   $@","   █   $@","       $@","       $@","        @@"],
    45: ["       $@","       $@","       $@","███████$@","       $@","       $@","       $@","       $@","        @@"],
    46: ["    $@","    $@","    $@","    $@","    $@","    $@"," ██ $@"," █▀ $@","     @@"],
    47: ["      ██$@","     ██ $@","    ██  $@","   ██   $@","  ██    $@"," ██     $@","██      $@","        $@","         @@"],
    48: [" ▄██████▄ $@","███    ███$@","███    ███$@","███    ███$@","███    ███$@","███    ███$@","███    ███$@"," ▀██████▀ $@","           @@"],
    49: ["    ▄█ $@","   ███ $@","  ████ $@","   ███ $@","   ███ $@","   ███ $@","   ███ $@"," ▄█████$@","       @@"],
    50: [" ▄███████▄ $@","██▀     ▄██$@","      ▄███▀$@","    ▄███▀  $@","  ▄███▀    $@","▄███▀      $@","███▄     ▄█$@"," ▀████████▀$@","            @@"],
    51: [" ▄███████▄ $@","██▀     ▄██$@","      ▄███▀$@","   ▄███▀   $@","      ▀███▄$@","██▄     ▀██$@","███▄   ▄███$@"," ▀███████▀ $@","            @@"],
    52: ["   ▄██   █▄$@","  ███   ███$@"," ███    ███$@","███     ███$@","███████████$@","        ███$@","        ███$@","        ▀█▀$@","            @@"],
    53: ["███████████$@","███        $@","███        $@","█████████▄ $@","        ██ $@","        ██ $@","███    ███ $@"," ▀██████▀  $@","            @@"],
    54: ["  ▄██████▄ $@"," ███    ██ $@","███        $@","█████████▄ $@","███     ██ $@","███     ██ $@","███    ███ $@"," ▀██████▀  $@","            @@"],
    55: ["███████████$@","        ███$@","       ███ $@","      ███  $@","     ███   $@","    ███    $@","   ███     $@","  ███      $@","            @@"],
    56: [" ▄██████▄ $@","███    ███$@","███    ███$@"," ▀██████▀ $@"," ▄██████▄ $@","███    ███$@","███    ███$@"," ▀██████▀ $@","           @@"],
    57: [" ▄██████▄ $@","███    ███$@","███    ███$@"," ▀████████$@","       ███$@","       ███$@","███    ███$@"," ▀██████▀ $@","           @@"],
    58: ["    $@","    $@"," ██ $@","    $@","    $@"," ██ $@","    $@","    $@","     @@"],
    59: ["    $@","    $@"," ██ $@","    $@","    $@"," ██ $@"," █▀ $@","    $@","     @@"],
    60: ["    ▄██$@","  ▄██▀ $@","▄██▀   $@","██     $@","▀██▄   $@","  ▀██▄ $@","    ▀██$@","       $@","        @@"],
    61: ["       $@","       $@","███████$@","       $@","███████$@","       $@","       $@","       $@","        @@"],
    62: ["██▄    $@"," ▀██▄  $@","   ▀██▄$@","     ██$@","   ▄██▀$@"," ▄██▀  $@","██▀    $@","       $@","        @@"],
    63: [" ▄███████▄ $@","██▀     ▄██$@","      ▄███▀$@","    ▄███▀  $@","   ███     $@","           $@","   ███     $@","   █▀      $@","            @@"],
    64: [" ▄██████▄  $@","██▀    ▀██ $@","██  ▄██▄██ $@","██ ██  ███ $@","██ ██  ███ $@","██  ▀███▀██$@","██▄      ▀ $@"," ▀██████▄  $@","            @@"],
    94: ["   ▄█▄   $@","  ██ ██  $@"," ██   ██ $@","         $@","         $@","         $@","         $@","         $@","          @@"],
    95: ["          $@","          $@","          $@","          $@","          $@","          $@","          $@","██████████$@","           @@"],
    74: ["     ▄█$@","    ███$@","    ███$@","    ███$@","    ███$@","    ███$@","    ███$@","█▄ ▄███$@","       @@"],
    75: ["   ▄█   ▄█▄$@","  ███ ▄███▀$@","  ███▐██▀  $@"," ▄█████▀   $@","▀▀█████▄   $@","  ███▐██▄  $@","  ███ ▀███▄$@","  ███   ▀█▀$@","           @@"],
    76: [" ▄█      $@","███      $@","███      $@","███      $@","███      $@","███      $@","███▌    ▄$@","█████▄▄██$@","         @@"],
    82: ["   ▄████████$@","  ███    ███$@","  ███    ███$@"," ▄███▄▄▄▄██▀$@","▀▀███▀▀▀▀▀  $@","▀███████████$@","  ███    ███$@","  ███    ███$@","            @@"],
    106: ["     ▄█$@","    ███$@","    ███$@","    ███$@","    ███$@","    ███$@","    ███$@","█▄ ▄███$@","       @@"],
    107: ["   ▄█   ▄█▄$@","  ███ ▄███▀$@","  ███▐██▀  $@"," ▄█████▀   $@","▀▀█████▄   $@","  ███▐██▄  $@","  ███ ▀███▄$@","  ███   ▀█▀$@","           @@"],
    108: [" ▄█      $@","███      $@","███      $@","███      $@","███      $@","███      $@","███▌    ▄$@","█████▄▄██$@","         @@"],
    114: ["   ▄████████$@","  ███    ███$@","  ███    ███$@"," ▄███▄▄▄▄██▀$@","▀▀███▀▀▀▀▀  $@","▀███████████$@","  ███    ███$@","  ███    ███$@","            @@"],
}
with open(FONT_FILE, 'r') as f:
    lines = f.readlines()
for ascii_code, char_lines in CHARS.items():
    start_line = 4 + (ascii_code - 32) * 9
    for i, new_line in enumerate(char_lines):
        lines[start_line + i] = new_line + '\n'
with open(FONT_FILE, 'w') as f:
    f.writelines(lines)
PATCH_SCRIPT

# Create the main script
echo "Creating main application..."
cat > "$SCRIPT_PATH" << 'MAINSCRIPT'
#!/bin/bash

# Suppress Vulkan warnings
export RADV_DEBUG=nohiz
export AMD_VULKAN_ICD=RADV
exec 2>/dev/null

# Screensaver ASCII Art Generator - Uses Delta Corps Priest 1 font
SCREENSAVER_FILE="$HOME/.config/omarchy/branding/screensaver.txt"
FONT_DIR="$HOME/.local/share/figlet"
FONT_FILE="$FONT_DIR/Delta-Corps-Priest-1.flf"
FONT_URL="https://raw.githubusercontent.com/xero/figlet-fonts/master/Delta%20Corps%20Priest%201.flf"

# Common zenity options for centered, non-fullscreen dialogs
ZENITY_OPTS="--modal"

# Function to run zenity with fixed size (prevents fullscreen)
run_zenity() {
    GDK_BACKEND=x11 zenity "$@" 2>/dev/null
}

# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
    zenity $ZENITY_OPTS --question \
        --title="Missing Dependency" \
        --text="The 'figlet' package is required.\n\nInstall it now?" \
        --width=400 --height=150

    if [ $? -eq 0 ]; then
        if command -v pacman &> /dev/null; then
            pkexec pacman -S --noconfirm figlet
        elif command -v apt &> /dev/null; then
            pkexec apt install -y figlet
        else
            zenity $ZENITY_OPTS --error --text="Please install 'figlet' manually." --width=300 --height=100
            exit 1
        fi
    else
        exit 1
    fi
fi

# Download font if not present
if [ ! -f "$FONT_FILE" ]; then
    mkdir -p "$FONT_DIR"
    zenity $ZENITY_OPTS --info --text="Downloading Delta Corps Priest 1 font..." --timeout=2 --width=300 --height=100 &
    curl -sL "$FONT_URL" -o "$FONT_FILE" 2>/dev/null
    if [ ! -f "$FONT_FILE" ]; then
        zenity $ZENITY_OPTS --error --text="Failed to download font." --width=300 --height=100
        exit 1
    fi
fi

# Get the word from user
WORD=$(zenity $ZENITY_OPTS --entry \
    --title="Screensaver Text Generator" \
    --text="Enter the word for your screensaver:" \
    --entry-text="OMARCHY" \
    --width=400 --height=150)

if [ $? -ne 0 ] || [ -z "$WORD" ]; then
    exit 0
fi

# Convert only letters to uppercase, preserve numbers and special characters
WORD=$(echo "$WORD" | tr '[:lower:]' '[:upper:]')

# Generate ASCII art with Delta Corps Priest 1 font (patched to support 0-9, !, $, %)
ASCII_ART=$(figlet -d "$FONT_DIR" -f "Delta-Corps-Priest-1" -w 10000 "$WORD" 2>/dev/null)

if [ -z "$ASCII_ART" ]; then
    zenity $ZENITY_OPTS --error --text="Failed to generate ASCII art." --width=300 --height=100
    exit 1
fi

# Check if text is too wide (more than 200 chars per line)
MAX_WIDTH=$(echo "$ASCII_ART" | awk '{ if (length > max) max = length } END { print max }')
if [ "$MAX_WIDTH" -gt 200 ]; then
    zenity $ZENITY_OPTS --warning \
        --title="Text Too Wide" \
        --text="The text is $MAX_WIDTH characters wide.\nConsider using a shorter word (max ~15 characters recommended)." \
        --width=400 --height=150
fi

# Preview - calculate window size based on content
PREVIEW_WIDTH=$((MAX_WIDTH * 10 + 100))
[ "$PREVIEW_WIDTH" -lt 800 ] && PREVIEW_WIDTH=800
[ "$PREVIEW_WIDTH" -gt 1600 ] && PREVIEW_WIDTH=1600

run_zenity $ZENITY_OPTS --text-info \
    --title="Preview (scroll right if needed)" \
    --filename=<(echo "$ASCII_ART") \
    --font="monospace 8" \
    --width=$PREVIEW_WIDTH --height=400 \
    --ok-label="Save" \
    --cancel-label="Cancel"

if [ $? -eq 0 ]; then
    mkdir -p "$(dirname "$SCREENSAVER_FILE")"
    [ -f "$SCREENSAVER_FILE" ] && cp "$SCREENSAVER_FILE" "${SCREENSAVER_FILE}.backup"
    echo "$ASCII_ART" > "$SCREENSAVER_FILE"
    zenity $ZENITY_OPTS --info --text="Screensaver updated!\nBackup saved as .backup" --width=300 --height=100
fi
MAINSCRIPT

chmod +x "$SCRIPT_PATH"

# Create desktop entry
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Screensaver Maker
Comment=Generate ASCII art screensavers
Exec=$SCRIPT_PATH
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;
EOF

echo ""
echo "Installation complete!"
echo "- Main script: $SCRIPT_PATH"
echo "- Desktop entry: $DESKTOP_FILE"
echo ""
echo "You can now find 'Screensaver Maker' in your app launcher."
echo "Or run it directly: $SCRIPT_NAME"
