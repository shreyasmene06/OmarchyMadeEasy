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

## Future Development

Additional scripts will be added over time as Omarchy expands and matures.
