# Omarchy Scripts

A collection of custom scripts designed to enhance and automate components of the **Omarchy** environment — a personalized Arch Linux + Hyprland workflow.  
Each script focuses on improved productivity, automated window management, and consistent system ricing.

---

## Scripts

### `rice.sh`

A workspace-setup script for **Hyprland** that automatically prepares a complete UI layout on **Workspace 3**.

#### Applications Launched

| Application | Placement | Purpose |
|------------|-----------|---------|
| Spotify | Left half | Music player 🎧 |
| Neofetch | Top-right | System overview |
| Peaclock | Bottom-right (left) | React-based clock |
| Cava | Bottom-right (right) | Audio visualizer 🎶 |

#### Key Features

- Automatically tiles and focuses windows to ensure proper layout
- Includes timing safeguards to prevent race conditions
- Closes the launching terminal after execution
- Validates installed applications and offers auto-install prompts
- <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ee9e977f-7627-4c1b-8260-388457dc00b3" />


#### Requirements

- Linux system with package manager: Pacman / Apt / DNF
- Hyprland + hyprctl
- Alacritty terminal

Required applications:
```
spotify, neofetch, cava, peaclock
```

#### Usage

```bash
chmod +x rice.sh
./rice.sh
```

**Tip:** Add a keybind in Hyprland for instant workspace setup.

---

### `screensaver-maker-installer.sh`

A utility script that automatically installs the Omarchy-compatible screensaver editor and makes it available as an application on the system.

#### Why This Script Exists

The built-in Omarchy screensaver uses a distinct ASCII font.  
Editing its artwork is possible, but matching the exact font manually is tedious and error-prone.

This script solves that by:

- Installing the correct Omarchy screensaver editor
- Allowing users to simply type text and generate a matching screensaver
- Preserving the unique Omarchy aesthetic without font inconsistencies

#### Features

- Streamlined one-command installation
- Auto-adds a Screensaver Maker tool to the system
- Ensures font and styling remain 100% Omarchy-accurate
- Improves customization workflow for users who rice their desktops
- <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/25afe442-82fa-4780-b563-a01352b22a02" />


#### Supported System

This tool is **exclusively supported on Omarchy**.  
It is not guaranteed to work on any other Linux distribution.

#### Usage

```bash
chmod +x screensaver-maker-installer.sh
./screensaver-maker-installer.sh
```

---

## Future Development

Additional scripts will be added over time as Omarchy expands and matures.
