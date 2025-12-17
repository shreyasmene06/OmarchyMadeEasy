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

### `motion-wallpaper.sh`

A lightweight script for dynamic wallpapers that cleanly integrates with Wayland + Hyprland systems. Users can simply select a GIF or video file from their file manager, and it will be applied directly as a live wallpaper — no extra configuration required.

Designed without any unnecessary extras:  
just choose a file → set it as your wallpaper → done.

#### Features

- Supports both **GIF** and **video** wallpapers
- File selection via user-friendly file picker
- Automatically handles wallpaper rendering in the background
- Focused on simplicity — minimal command usage
- Clean replacement of old wallpaper instances
- <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8db65a6d-fdc9-49b2-8c93-904648aee286" />


#### Requirements

- Hyprland (Wayland compositor)
- Pipewire recommended for good video performance
- A compatible media renderer (e.g., `mpvpaper` or similar)

#### Supported Systems

| Distribution | Status |
|-------------|--------|
| Omarchy | ✔ Tested & Supported |
| Arch Linux + Hyprland | ✔ Confirmed working |
| Other Arch-based Hyprland systems | Likely compatible but not officially tested |

#### Usage

```bash
chmod +x motion-wallpaper.sh
./motion-wallpaper.sh
```

---

### `enable-vibrance.sh`

A setup script that enhances the display output on Hyprland using **hyprshade** and a custom color-tuning shader. It is designed to **make your screen look closer to OLED** with stronger color depth, richer blacks, and higher contrast — without oversharpening or distorting the image.

Run once, and the effect is automatically applied every session.

#### What This Script Does

- Installs a custom GLSL shader inspired by NVIDIA Control Panel color controls
- Enables deeper contrast and boosted vibrance for an **OLED-like appearance**
- Creates the required shader directory automatically
- Adds the startup execution line in Hyprland config (only once)
- Backs up your current config for safety
- Reloads Hyprland on completion
- <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/54192fde-c7aa-4c96-ba86-8bcdc5bbceb1" />


#### Visual Improvements Applied

| Enhancement | Purpose |
|------------|---------|
| Digital Vibrance | Boosts saturation for richer colors |
| Contrast | Deepens blacks and improves visual depth |
| Brightness | Controlled lift without washing out shadows |
| Gamma | Balanced mid-tones for more natural scene lighting |

All values can be easily fine-tuned in the shader file.

#### Requirements

- Hyprland compositor
- hyprshade installed
- GPU with GLSL ES 3.0 compatibility

#### Supported Systems

| System | Status |
|--------|--------|
| Omarchy | ✔ Fully supported |
| Arch Linux + Hyprland | ✔ Compatible |
| Other Arch-based Hyprland setups | Expected to work |

#### Usage

```bash
chmod +x enable-vibrance.sh
./enable-vibrance.sh
```

After running, your screen will reload with the enhanced vibrance and contrast applied.

To disable later, simply remove the injected line from:
```
~/.config/hypr/hyprland.conf
```

#### Customization

Edit:
```
~/.config/hypr/shaders/vibrance.glsl
```

Example variable block:
```glsl
float vibrance = 0.5;
float contrast = 1.1;
float brightness = 0.0;
float gamma = 1.0;
```

Adjust to your preferred display feel — dark mode gaming, cinematic tones, or a bright OLED-like finish.

---

## Dotfiles

This repository also includes a complete set of configuration files for the **Omarchy** environment, providing a consistent and polished setup across all components.

### Included Configurations

| Component | Description |
|-----------|-------------|
| **hypr/** | Complete Hyprland configuration including bindings, monitors, input, autostart, and 140+ custom GLSL shaders |
| **waybar/** | Top bar configuration with custom styling and modules |
| **kitty/** | Terminal emulator configuration with JetBrainsMono Nerd Font |
| **walker/** | Application launcher configuration with custom keybinds and providers |
| **neofetch/** | System information display with custom theming |
| **hyprlock/** | Screen lock configuration |
| **hypridle/** | Idle management settings |
| **hyprpaper/** | Wallpaper daemon configuration |
| **hyprland-preview-share-picker/** | Screen sharing picker styling |
| **systemd/** | User service configurations |
| **libreoffice/** | Office suite customization |

### Notable Features

- **140+ GLSL Shaders** — Extensive collection including cyberpunk themes, CRT effects, retro aesthetics, color grading, and creative filters
- **Modular Hyprland Setup** — Split configuration files for easy customization (bindings, monitors, input, autostart, etc.)
- **Consistent Theming** — All components integrate with Omarchy's theme system
- **Optimized for Workflow** — Keybinds and settings designed for productivity

### Usage

Copy the desired configuration files to your `~/.config/` directory:

```bash
cp -r dotfiles/hypr ~/.config/
cp -r dotfiles/waybar ~/.config/
cp -r dotfiles/kitty ~/.config/
# ... etc
```

**Note:** These dotfiles are specifically configured for the Omarchy environment and may require adjustments for use on other systems.

---

# Live Wallpaper Manager Installer for Hyprland

A single run installer that sets up a Live Wallpaper TUI manager on Arch based Hyprland setups. It installs the script locally, adds a Hyprland keybind to open it in a floating Kitty window, and reloads Hyprland so the bind works immediately.

## What This Script Does

1. Installs `live-wall.sh` to `~/.local/bin/live-wall.sh`
2. Creates the config directory `~/.config/live-wall` and the file `wallpapers.conf`
3. Adds a Hyprland keybind in `~/.config/hypr/bindings.conf` only if not already present
4. Adds floating window rules for the popup terminal
5. Reloads Hyprland after updating config when `hyprctl` is available
6. Checks for required dependencies and prints install commands if missing

## Keybind Installed

Opens the manager in Kitty as a floating window.

Keybind

`SUPER + W`

## Requirements

1. Hyprland
2. kitty
3. linux wallpaper engine

The script uses the command `linux-wallpaperengine`.

## Install

Run directly from GitHub.

```bash
curl -fsSL https://raw.githubusercontent.com/shreyasmene06/OmarchyMadeEasy/main/install-live-wall.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/shreyasmene06/OmarchyMadeEasy/main/install-live-wall.sh | bash -s -- --uninstall
```

Uninstall removes the installed script and deletes the injected keybind block from `~/.config/hypr/bindings.conf`. Your wallpaper list is kept at `~/.config/live-wall`.

## Notes

1. The popup uses `kitty --class floating-term` and Hyprland window rules match `class:^(floating-term)$`
2. The installer backs up `~/.config/hypr/bindings.conf` to `bindings.conf.backup` before editing
3. The wallpaper engine target is currently hardcoded as `--screen-root eDP-1` inside `live-wall.sh`

If your monitor output name differs, update the output in `live-wall.sh`.

# Live Wallpaper Manager Installer for Hyprland

A single run installer that sets up a Live Wallpaper TUI manager on Arch based Hyprland setups. It installs the script locally, adds a Hyprland keybind to open it in a floating Kitty window, and reloads Hyprland so the bind works immediately.

## What This Script Does

1. Installs `live-wall.sh` to `~/.local/bin/live-wall.sh`
2. Creates the config directory `~/.config/live-wall` and the file `wallpapers.conf`
3. Adds a Hyprland keybind in `~/.config/hypr/bindings.conf` only if not already present
4. Adds floating window rules for the popup terminal
5. Reloads Hyprland after updating config when `hyprctl` is available
6. Checks for required dependencies and prints install commands if missing

## Keybind Installed

Opens the manager in Kitty as a floating window.

Keybind

`SUPER + W`

## Requirements

1. Hyprland
2. kitty
3. linux wallpaper engine

The script uses the command `linux-wallpaperengine`.

## Install

Run directly from GitHub.

```bash
curl -fsSL https://raw.githubusercontent.com/shreyasmene06/OmarchyMadeEasy/main/install-live-wall.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/shreyasmene06/OmarchyMadeEasy/main/install-live-wall.sh | bash -s -- --uninstall
```

Uninstall removes the installed script and deletes the injected keybind block from `~/.config/hypr/bindings.conf`. Your wallpaper list is kept at `~/.config/live-wall`.

## Notes

1. The popup uses `kitty --class floating-term` and Hyprland window rules match `class:^(floating-term)$`
2. The installer backs up `~/.config/hypr/bindings.conf` to `bindings.conf.backup` before editing
3. The wallpaper engine target is currently hardcoded as `--screen-root eDP-1` inside `live-wall.sh`

If your monitor output name differs, update the output in `live-wall.sh`.

## Future Development

Additional scripts will be added over time as Omarchy expands and matures.
