#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Neofetch ASCII Art Setter — Terminal Edition
#  Part of OmarchyMadeEasy
#
#  Usage:
#    ./set-ascii.sh              Interactive paste mode
#    ./set-ascii.sh -f FILE      Load ASCII art from a file
#    ./set-ascii.sh -r           Reset to default distro logo
#    ./set-ascii.sh -s           Show current custom ASCII art
#    ./set-ascii.sh -h           Show help
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# ── Colors & Formatting ──────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BG_PURPLE='\033[48;5;53m'

# ── Paths ─────────────────────────────────────────────────────
NEOFETCH_CONFIG_DIR="$HOME/.config/neofetch"
NEOFETCH_CONFIG="$NEOFETCH_CONFIG_DIR/config.conf"
CUSTOM_ASCII_FILE="$NEOFETCH_CONFIG_DIR/custom_ascii.txt"
CONFIG_BACKUP="$NEOFETCH_CONFIG_DIR/config.conf.bak"

# ── Helper Functions ──────────────────────────────────────────

banner() {
    echo ""
    echo -e "  ${MAGENTA}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "  ${MAGENTA}║${RESET}  ${WHITE}⌨  Neofetch ASCII Art Setter${RESET}               ${MAGENTA}║${RESET}"
    echo -e "  ${MAGENTA}║${RESET}  ${DIM}${CYAN}Terminal Edition — OmarchyMadeEasy${RESET}         ${MAGENTA}║${RESET}"
    echo -e "  ${MAGENTA}╚══════════════════════════════════════════════╝${RESET}"
    echo ""
}

success() {
    echo -e "  ${GREEN}✓${RESET} $1"
}

error() {
    echo -e "  ${RED}✗${RESET} $1" >&2
}

info() {
    echo -e "  ${BLUE}ℹ${RESET} $1"
}

warn() {
    echo -e "  ${YELLOW}⚠${RESET} $1"
}

divider() {
    echo -e "  ${DIM}──────────────────────────────────────────────${RESET}"
}

# ── Core Functions ────────────────────────────────────────────

check_neofetch_config() {
    if [[ ! -f "$NEOFETCH_CONFIG" ]]; then
        error "Neofetch config not found at ${CYAN}$NEOFETCH_CONFIG${RESET}"
        error "Make sure neofetch is installed and has been run at least once."
        exit 1
    fi
}

backup_config() {
    if [[ ! -f "$CONFIG_BACKUP" ]]; then
        cp "$NEOFETCH_CONFIG" "$CONFIG_BACKUP"
        success "Backed up original config to ${CYAN}config.conf.bak${RESET}"
    fi
}

update_image_source() {
    local value="$1"
    # Replace image_source="..." in the config
    sed -i "s|^image_source=\"[^\"]*\"|image_source=\"${value}\"|" "$NEOFETCH_CONFIG"
}

preview_ascii() {
    local art="$1"
    echo ""
    divider
    echo -e "  ${WHITE}${BOLD}Preview:${RESET}"
    divider
    echo ""
    # Display the art with cyan coloring, indented
    while IFS= read -r line; do
        echo -e "  ${CYAN}${line}${RESET}"
    done <<< "$art"
    echo ""
    divider
}

confirm_action() {
    local prompt="$1"
    echo ""
    echo -ne "  ${YELLOW}?${RESET} ${prompt} ${DIM}[y/N]${RESET} "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# ── Commands ──────────────────────────────────────────────────

cmd_interactive() {
    banner
    check_neofetch_config

    info "Paste or type your ASCII art below."
    info "When done, press ${WHITE}Ctrl+D${RESET} on a new line to finish."
    info "Press ${WHITE}Ctrl+C${RESET} to cancel."
    echo ""
    echo -e "  ${DIM}─── Start pasting below this line ───${RESET}"
    echo ""

    # Read multiline input until EOF (Ctrl+D)
    local ascii_art=""
    ascii_art=$(cat)

    # Check if anything was entered
    if [[ -z "${ascii_art// /}" ]] || [[ -z "$(echo "$ascii_art" | tr -d '[:space:]')" ]]; then
        echo ""
        error "No ASCII art entered. Aborting."
        exit 1
    fi

    # Show preview
    preview_ascii "$ascii_art"

    # Line/char stats
    local line_count char_count
    line_count=$(echo "$ascii_art" | wc -l)
    char_count=$(echo -n "$ascii_art" | wc -c)
    info "${WHITE}${line_count}${RESET} lines, ${WHITE}${char_count}${RESET} characters"

    # Confirm
    if confirm_action "Set this as your neofetch ASCII art?"; then
        echo ""
        backup_config
        
        # Save the ASCII art
        mkdir -p "$NEOFETCH_CONFIG_DIR"
        echo "$ascii_art" > "$CUSTOM_ASCII_FILE"
        success "Saved art to ${CYAN}$CUSTOM_ASCII_FILE${RESET}"

        # Update config
        update_image_source "$CUSTOM_ASCII_FILE"
        success "Updated ${CYAN}config.conf${RESET} → image_source points to your art"

        echo ""
        echo -e "  ${GREEN}${BOLD}🎉 Done!${RESET} Run ${MAGENTA}neofetch${RESET} to see your new ASCII art."
        echo ""
    else
        echo ""
        warn "Cancelled. Nothing was changed."
        echo ""
    fi
}

cmd_from_file() {
    local filepath="$1"
    banner
    check_neofetch_config

    # Resolve relative paths
    filepath="$(realpath "$filepath" 2>/dev/null || echo "$filepath")"

    if [[ ! -f "$filepath" ]]; then
        error "File not found: ${CYAN}$filepath${RESET}"
        exit 1
    fi

    local ascii_art
    ascii_art=$(cat "$filepath")

    if [[ -z "$(echo "$ascii_art" | tr -d '[:space:]')" ]]; then
        error "File is empty or contains only whitespace."
        exit 1
    fi

    info "Loading art from ${CYAN}$filepath${RESET}"
    preview_ascii "$ascii_art"

    local line_count char_count
    line_count=$(echo "$ascii_art" | wc -l)
    char_count=$(echo -n "$ascii_art" | wc -c)
    info "${WHITE}${line_count}${RESET} lines, ${WHITE}${char_count}${RESET} characters"

    if confirm_action "Set this as your neofetch ASCII art?"; then
        echo ""
        backup_config

        mkdir -p "$NEOFETCH_CONFIG_DIR"
        cp "$filepath" "$CUSTOM_ASCII_FILE"
        success "Copied art to ${CYAN}$CUSTOM_ASCII_FILE${RESET}"

        update_image_source "$CUSTOM_ASCII_FILE"
        success "Updated ${CYAN}config.conf${RESET} → image_source points to your art"

        echo ""
        echo -e "  ${GREEN}${BOLD}🎉 Done!${RESET} Run ${MAGENTA}neofetch${RESET} to see your new ASCII art."
        echo ""
    else
        echo ""
        warn "Cancelled. Nothing was changed."
        echo ""
    fi
}

cmd_reset() {
    banner
    check_neofetch_config

    if confirm_action "Reset neofetch to the default distro ASCII art?"; then
        echo ""
        update_image_source "auto"
        success "Set image_source back to ${CYAN}\"auto\"${RESET}"

        if [[ -f "$CUSTOM_ASCII_FILE" ]]; then
            rm "$CUSTOM_ASCII_FILE"
            success "Removed ${CYAN}custom_ascii.txt${RESET}"
        fi

        echo ""
        echo -e "  ${GREEN}${BOLD}✓ Reset complete.${RESET} Neofetch will show the default distro logo."
        echo ""
    else
        echo ""
        warn "Cancelled. Nothing was changed."
        echo ""
    fi
}

cmd_show() {
    banner
    check_neofetch_config

    # Check current image_source
    local current
    current=$(grep -oP 'image_source="\K[^"]+' "$NEOFETCH_CONFIG" 2>/dev/null || echo "unknown")

    if [[ "$current" == "auto" ]] || [[ "$current" == "ascii" ]]; then
        info "Currently using: ${WHITE}Default distro ASCII art${RESET} (image_source=\"${current}\")"
        echo ""
    elif [[ -f "$current" ]]; then
        info "Currently using custom art from: ${CYAN}$current${RESET}"
        echo ""
        divider
        echo -e "  ${WHITE}${BOLD}Current Art:${RESET}"
        divider
        echo ""
        while IFS= read -r line; do
            echo -e "  ${CYAN}${line}${RESET}"
        done < "$current"
        echo ""
        divider
        echo ""
    else
        warn "image_source points to ${CYAN}$current${RESET} but file doesn't exist."
        echo ""
    fi
}

cmd_help() {
    banner
    echo -e "  ${WHITE}${BOLD}Usage:${RESET}"
    echo ""
    echo -e "    ${GREEN}./set-ascii.sh${RESET}              ${DIM}Interactive mode — paste art, press Ctrl+D${RESET}"
    echo -e "    ${GREEN}./set-ascii.sh -f ${ITALIC}FILE${RESET}      ${DIM}Load ASCII art from a file${RESET}"
    echo -e "    ${GREEN}./set-ascii.sh -r${RESET}           ${DIM}Reset to default distro logo${RESET}"
    echo -e "    ${GREEN}./set-ascii.sh -s${RESET}           ${DIM}Show current ASCII art${RESET}"
    echo -e "    ${GREEN}./set-ascii.sh -h${RESET}           ${DIM}Show this help${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}Examples:${RESET}"
    echo ""
    echo -e "    ${DIM}# Paste mode — type/paste art, then Ctrl+D to finish${RESET}"
    echo -e "    ${CYAN}\$ ./set-ascii.sh${RESET}"
    echo ""
    echo -e "    ${DIM}# From a file${RESET}"
    echo -e "    ${CYAN}\$ ./set-ascii.sh -f ~/my-cool-art.txt${RESET}"
    echo ""
    echo -e "    ${DIM}# Pipe in art${RESET}"
    echo -e "    ${CYAN}\$ cat art.txt | ./set-ascii.sh${RESET}"
    echo ""
    echo -e "    ${DIM}# Reset back to default${RESET}"
    echo -e "    ${CYAN}\$ ./set-ascii.sh -r${RESET}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────

main() {
    # No arguments → interactive mode
    if [[ $# -eq 0 ]]; then
        # Check if stdin is a pipe (for cat file | ./set-ascii.sh)
        if [[ ! -t 0 ]]; then
            # Data is being piped in
            local ascii_art
            ascii_art=$(cat)

            if [[ -z "$(echo "$ascii_art" | tr -d '[:space:]')" ]]; then
                error "Piped input is empty."
                exit 1
            fi

            banner
            check_neofetch_config
            info "Received art from pipe."
            preview_ascii "$ascii_art"

            local line_count char_count
            line_count=$(echo "$ascii_art" | wc -l)
            char_count=$(echo -n "$ascii_art" | wc -c)
            info "${WHITE}${line_count}${RESET} lines, ${WHITE}${char_count}${RESET} characters"

            # When piped, auto-confirm (non-interactive)
            echo ""
            backup_config
            mkdir -p "$NEOFETCH_CONFIG_DIR"
            echo "$ascii_art" > "$CUSTOM_ASCII_FILE"
            success "Saved art to ${CYAN}$CUSTOM_ASCII_FILE${RESET}"
            update_image_source "$CUSTOM_ASCII_FILE"
            success "Updated ${CYAN}config.conf${RESET}"
            echo ""
            echo -e "  ${GREEN}${BOLD}🎉 Done!${RESET} Run ${MAGENTA}neofetch${RESET} to see your new ASCII art."
            echo ""
        else
            cmd_interactive
        fi
        return
    fi

    # Parse arguments
    case "${1:-}" in
        -f|--file)
            if [[ -z "${2:-}" ]]; then
                error "Missing file path. Usage: ${GREEN}./set-ascii.sh -f FILE${RESET}"
                exit 1
            fi
            cmd_from_file "$2"
            ;;
        -r|--reset)
            cmd_reset
            ;;
        -s|--show)
            cmd_show
            ;;
        -h|--help)
            cmd_help
            ;;
        *)
            error "Unknown option: ${WHITE}$1${RESET}"
            echo ""
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
