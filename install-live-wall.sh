#!/bin/bash

# Live Wallpaper Installer Script
# Run this script to install the Live Wallpaper Manager on your system
# curl -fsSL https://raw.githubusercontent.com/shreyasmene06/OmarchyMadeEasy/main/install-live-wall.sh | bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_NAME="live-wall.sh"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/live-wall"
HYPRLAND_BINDINGS="$HOME/.config/hypr/bindings.conf"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}        ${PURPLE}Live Wallpaper Installer${NC}                            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}        ${WHITE}For Arch + Hyprland${NC}                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Generate the live-wall.sh script
generate_script() {
    echo -e "${YELLOW}[*] Installing live-wall.sh...${NC}"
    
    cat > "$INSTALL_DIR/$SCRIPT_NAME" << 'LIVE_WALL_SCRIPT'
#!/bin/bash

# Live Wallpaper TUI Manager for Arch + Hyprland
# Uses linux-wallpaperengine to apply wallpapers

CONFIG_DIR="$HOME/.config/live-wall"
CONFIG_FILE="$CONFIG_DIR/wallpapers.conf"
WORKSPACE=5

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Initialize config directory and file
init_config() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    if [[ ! -f "$CONFIG_FILE" ]]; then
        touch "$CONFIG_FILE"
    fi
}

# Clear screen and show header
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}        ${PURPLE}Live Wallpaper Manager${NC}                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}        ${WHITE}Arch + Hyprland Edition${NC}                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Show all saved wallpapers
list_wallpapers() {
    echo -e "${YELLOW}Saved Wallpapers:${NC}"
    echo -e "${WHITE}────────────────────────────────────────${NC}"
    
    if [[ ! -s "$CONFIG_FILE" ]]; then
        echo -e "${RED}   No wallpapers saved yet.${NC}"
        return 1
    fi
    
    local i=1
    while IFS='|' read -r name code; do
        if [[ -n "$name" && -n "$code" ]]; then
            echo -e "   ${GREEN}[$i]${NC} ${WHITE}$name${NC} ${BLUE}(Code: $code)${NC}"
            ((i++))
        fi
    done < "$CONFIG_FILE"
    echo -e "${WHITE}────────────────────────────────────────${NC}"
    return 0
}

# Add a new wallpaper
add_wallpaper() {
    show_header
    echo -e "${PURPLE}[+] Add New Wallpaper${NC}"
    echo -e "${WHITE}────────────────────────────────────────${NC}"
    echo ""
    
    # Get wallpaper name
    echo -ne "${CYAN}Enter wallpaper name: ${NC}"
    read -r name
    
    if [[ -z "$name" ]]; then
        echo -e "${RED}[!] Name cannot be empty!${NC}"
        sleep 2
        return 1
    fi
    
    # Check if name already exists
    if grep -q "^$name|" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${RED}[!] A wallpaper with this name already exists!${NC}"
        sleep 2
        return 1
    fi
    
    # Get wallpaper code
    echo -ne "${CYAN}Enter wallpaper code (e.g., 1214148605): ${NC}"
    read -r code
    
    if [[ -z "$code" ]]; then
        echo -e "${RED}[!] Code cannot be empty!${NC}"
        sleep 2
        return 1
    fi
    
    # Validate code is numeric
    if ! [[ "$code" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[!] Code must be numeric!${NC}"
        sleep 2
        return 1
    fi
    
    # Save to config file
    echo "$name|$code" >> "$CONFIG_FILE"
    echo ""
    echo -e "${GREEN}[+] Wallpaper '$name' added successfully!${NC}"
    sleep 2
}

# Apply selected wallpaper
apply_wallpaper() {
    show_header
    echo -e "${PURPLE}[>] Select Wallpaper to Apply${NC}"
    echo ""
    
    if ! list_wallpapers; then
        echo ""
        echo -e "${YELLOW}Press any key to go back...${NC}"
        read -n 1
        return
    fi
    
    # Count wallpapers (only lines with valid format)
    local count=$(grep -E '^[^|]+\|[^|]+$' "$CONFIG_FILE" 2>/dev/null | wc -l)
    
    echo ""
    echo -ne "${CYAN}Enter wallpaper number (1-$count) or 'b' to go back: ${NC}"
    read -r choice
    
    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        return
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "$count" ]]; then
        echo -e "${RED}[!] Invalid selection!${NC}"
        sleep 2
        return
    fi
    
    # Get the selected wallpaper (from filtered valid lines only)
    local selected_line=$(grep -E '^[^|]+\|[^|]+$' "$CONFIG_FILE" | sed -n "${choice}p")
    local name=$(echo "$selected_line" | cut -d'|' -f1)
    local code=$(echo "$selected_line" | cut -d'|' -f2)
    
    echo ""
    echo -e "${YELLOW}[*] Applying wallpaper: ${WHITE}$name${NC}"
    echo -e "${BLUE}   Code: $code${NC}"
    echo ""
    
    # Kill any existing wallpaper engine process (use SIGKILL to ensure child processes die)
    pkill -9 -f "linux-wallpaperengine" 2>/dev/null
    sleep 0.5
    
    # Run the wallpaper engine in the background (no visible terminal)
    # Using setsid to completely detach the process from this shell
    setsid linux-wallpaperengine --screen-root eDP-1 --scaling stretch --no-audio "$code" > /dev/null 2>&1 &
    
    echo -e "${GREEN}[+] Wallpaper applied! Running invisibly in background${NC}"
    sleep 2
}

# Delete a wallpaper
delete_wallpaper() {
    show_header
    echo -e "${PURPLE}[-] Delete Wallpaper${NC}"
    echo ""
    
    if ! list_wallpapers; then
        echo ""
        echo -e "${YELLOW}Press any key to go back...${NC}"
        read -n 1
        return
    fi
    
    local count=$(grep -E '^[^|]+\|[^|]+$' "$CONFIG_FILE" 2>/dev/null | wc -l)
    
    echo ""
    echo -ne "${CYAN}Enter wallpaper number to delete (1-$count) or 'b' to go back: ${NC}"
    read -r choice
    
    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        return
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "$count" ]]; then
        echo -e "${RED}[!] Invalid selection!${NC}"
        sleep 2
        return
    fi
    
    # Get selected line from valid entries
    local selected_line=$(grep -E '^[^|]+\|[^|]+$' "$CONFIG_FILE" | sed -n "${choice}p")
    local name=$(echo "$selected_line" | cut -d'|' -f1)
    
    # Find the actual line number in the file for this entry
    local actual_line=$(grep -n -E '^[^|]+\|[^|]+$' "$CONFIG_FILE" | sed -n "${choice}p" | cut -d':' -f1)
    
    echo -ne "${YELLOW}Are you sure you want to delete '$name'? (y/n): ${NC}"
    read -r confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        sed -i "${actual_line}d" "$CONFIG_FILE"
        echo -e "${GREEN}[+] Wallpaper deleted!${NC}"
    else
        echo -e "${BLUE}[i] Cancelled.${NC}"
    fi
    sleep 2
}

# Stop current wallpaper
stop_wallpaper() {
    echo -e "${YELLOW}[*] Stopping live wallpaper...${NC}"
    # Use SIGKILL to ensure both wrapper script and actual binary are killed
    pkill -9 -f "linux-wallpaperengine" 2>/dev/null
    sleep 0.5
    # Double-check and kill any remaining processes
    pkill -9 -f "linux-wallpaperengine" 2>/dev/null
    echo -e "${GREEN}[+] Wallpaper stopped!${NC}"
    sleep 2
}

# Main menu
main_menu() {
    while true; do
        show_header
        
        echo -e "${WHITE}   What would you like to do?${NC}"
        echo ""
        echo -e "   ${GREEN}[1]${NC} Apply Wallpaper"
        echo -e "   ${GREEN}[2]${NC} Add New Wallpaper"
        echo -e "   ${GREEN}[3]${NC} View All Wallpapers"
        echo -e "   ${GREEN}[4]${NC} Delete Wallpaper"
        echo -e "   ${GREEN}[5]${NC} Stop Current Wallpaper"
        echo -e "   ${GREEN}[q]${NC} Quit"
        echo ""
        echo -ne "${CYAN}Enter your choice: ${NC}"
        
        read -r choice
        
        case $choice in
            1)
                apply_wallpaper
                ;;
            2)
                add_wallpaper
                ;;
            3)
                show_header
                list_wallpapers
                echo ""
                echo -e "${YELLOW}Press any key to continue...${NC}"
                read -n 1
                ;;
            4)
                delete_wallpaper
                ;;
            5)
                stop_wallpaper
                ;;
            q|Q)
                clear
                echo -e "${CYAN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Installation function
install_tui() {
    echo -e "${CYAN}Installing Live Wallpaper TUI...${NC}"
    
    # Create config directory
    init_config
    
    # Install to /usr/local/bin
    local install_path="/usr/local/bin/live-wall"
    
    if sudo cp "$0" "$install_path" && sudo chmod +x "$install_path"; then
        echo -e "${GREEN}[+] Installed successfully!${NC}"
        echo -e "${WHITE}    You can now run 'live-wall' from anywhere.${NC}"
    else
        echo -e "${RED}[!] Installation failed! Try running with sudo.${NC}"
        exit 1
    fi
}

# Uninstall function
uninstall_tui() {
    echo -e "${YELLOW}Uninstalling Live Wallpaper TUI...${NC}"
    
    if sudo rm -f "/usr/local/bin/live-wall"; then
        echo -e "${GREEN}[+] Uninstalled successfully!${NC}"
        echo -e "${BLUE}[i] Config files kept at: $CONFIG_DIR${NC}"
    else
        echo -e "${RED}[!] Uninstall failed!${NC}"
        exit 1
    fi
}

# Parse arguments
case "$1" in
    --install|-i)
        install_tui
        exit 0
        ;;
    --uninstall|-u)
        uninstall_tui
        exit 0
        ;;
    --help|-h)
        echo "Live Wallpaper TUI Manager"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  --install, -i    Install TUI system-wide"
        echo "  --uninstall, -u  Uninstall TUI"
        echo "  --help, -h       Show this help message"
        echo ""
        echo "Run without arguments to start the TUI."
        exit 0
        ;;
    "")
        # Initialize and run main menu
        init_config
        main_menu
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
LIVE_WALL_SCRIPT

    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    echo -e "${GREEN}[+] Installed to: $INSTALL_DIR/$SCRIPT_NAME${NC}"
}

# Add keybind and window rules to Hyprland bindings.conf
add_keybind() {
    echo -e "${YELLOW}[*] Setting up Hyprland keybind...${NC}"
    
    # Check if bindings.conf exists
    if [[ ! -f "$HYPRLAND_BINDINGS" ]]; then
        echo -e "${RED}[!] Hyprland bindings.conf not found at: $HYPRLAND_BINDINGS${NC}"
        echo -e "${YELLOW}[i] You can manually add these lines to your Hyprland config:${NC}"
        echo -e "${WHITE}    # Live Wallpaper TUI popup${NC}"
        echo -e "${WHITE}    bind = SUPER, W, exec, kitty --class floating-term -e $INSTALL_DIR/$SCRIPT_NAME${NC}"
        echo -e "${WHITE}    windowrulev2 = float, class:^(floating-term)\$${NC}"
        echo -e "${WHITE}    windowrulev2 = size 600 400, class:^(floating-term)\$${NC}"
        echo -e "${WHITE}    windowrulev2 = center, class:^(floating-term)\$${NC}"
        return 1
    fi
    
    # Check if keybind already exists
    if grep -q "live-wall" "$HYPRLAND_BINDINGS" 2>/dev/null; then
        echo -e "${BLUE}[i] Live wallpaper keybind already exists in config.${NC}"
        return 0
    fi
    
    # Backup the config
    cp "$HYPRLAND_BINDINGS" "$HYPRLAND_BINDINGS.backup"
    echo -e "${BLUE}[i] Config backed up to: $HYPRLAND_BINDINGS.backup${NC}"
    
    # Add keybind and window rules
    cat >> "$HYPRLAND_BINDINGS" << EOF

# Live Wallpaper TUI popup
bind = SUPER, W, exec, kitty --class floating-term -e $INSTALL_DIR/$SCRIPT_NAME
windowrulev2 = float, class:^(floating-term)\$
windowrulev2 = size 600 400, class:^(floating-term)\$
windowrulev2 = center, class:^(floating-term)\$
EOF
    
    echo -e "${GREEN}[+] Keybind added: SUPER + W (floating 600x400 centered)${NC}"
    
    # Reload Hyprland
    if command -v hyprctl &> /dev/null; then
        hyprctl reload 2>/dev/null
        echo -e "${GREEN}[+] Hyprland config reloaded!${NC}"
    fi
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}[*] Checking dependencies...${NC}"
    
    local missing_deps=()
    
    # Check for linux-wallpaperengine
    if ! command -v linux-wallpaperengine &> /dev/null; then
        missing_deps+=("linux-wallpaperengine")
    fi
    
    # Check for kitty (terminal)
    if ! command -v kitty &> /dev/null; then
        missing_deps+=("kitty")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}[i] Please install them before using the live wallpaper manager.${NC}"
        echo ""
        echo -e "${WHITE}    For linux-wallpaperengine:${NC}"
        echo -e "${BLUE}    yay -S linux-wallpaperengine-git${NC}"
        echo ""
        echo -e "${WHITE}    For kitty:${NC}"
        echo -e "${BLUE}    sudo pacman -S kitty${NC}"
        echo ""
    else
        echo -e "${GREEN}[+] All dependencies found!${NC}"
    fi
}

# Uninstall function
uninstall() {
    echo -e "${YELLOW}[*] Uninstalling Live Wallpaper Manager...${NC}"
    
    # Remove script
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        rm -f "$INSTALL_DIR/$SCRIPT_NAME"
        echo -e "${GREEN}[+] Removed script from: $INSTALL_DIR${NC}"
    fi
    
    # Remove keybind from Hyprland bindings.conf
    if [[ -f "$HYPRLAND_BINDINGS" ]]; then
        sed -i '/# Live Wallpaper TUI popup/d' "$HYPRLAND_BINDINGS"
        sed -i '/live-wall/d' "$HYPRLAND_BINDINGS"
        sed -i '/floating-term.*live-wall/d' "$HYPRLAND_BINDINGS"
        echo -e "${GREEN}[+] Removed keybind from Hyprland config${NC}"
        
        # Reload Hyprland
        if command -v hyprctl &> /dev/null; then
            hyprctl reload 2>/dev/null
        fi
    fi
    
    echo -e "${GREEN}[+] Uninstallation complete!${NC}"
    echo -e "${BLUE}[i] Config files kept at: $CONFIG_DIR${NC}"
    echo -e "${BLUE}[i] To remove config: rm -rf $CONFIG_DIR${NC}"
    
    exit 0
}

# Show help
show_help() {
    echo "Live Wallpaper Installer"
    echo ""
    echo "Usage: curl -fsSL <URL> | bash"
    echo "   or: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --uninstall, -u    Uninstall the live wallpaper manager"
    echo "  --help, -h         Show this help message"
    echo ""
    echo "Run without arguments to install the live wallpaper manager."
    exit 0
}

# Main installation
main_install() {
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    generate_script
    add_keybind
    check_dependencies
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}        ${WHITE}Installation Complete!${NC}                               ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}   Script installed to:${NC} $INSTALL_DIR/$SCRIPT_NAME"
    echo -e "${WHITE}   Keybind:${NC} SUPER + W (floating 600x400 centered)"
    echo -e "${WHITE}   Config directory:${NC} $CONFIG_DIR"
    echo ""
}

# Parse arguments
case "$1" in
    --uninstall|-u)
        uninstall
        ;;
    --help|-h)
        show_help
        ;;
    "")
        main_install
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
