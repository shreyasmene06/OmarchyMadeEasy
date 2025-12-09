#!/usr/bin/env bash

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
SHADER_DIR="$HOME/.config/hypr/shaders"
SHADER_FILE="$SHADER_DIR/vibrance.glsl"
COMMAND="exec = hyprshade on vibrance"

echo ">>> Setting up Vibrance Shader..."

# Backup config
if [ -f "$HYPR_CONF" ]; then
    cp "$HYPR_CONF" "$HYPR_CONF.bak"
    echo "✔ Backup created: hyprland.conf.bak"
fi

# Create shader directory
mkdir -p "$SHADER_DIR"

# Write shader content
cat > "$SHADER_FILE" << 'EOF'
// NVIDIA Control Panel Replica (All 5 Sliders)
#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    // --- YOUR SETTINGS (Match the Screenshot) ---

    // 1. Digital Vibrance (50% is default/0.0. Higher = Colorful)
    float vibrance = 0.5;

    // 2. Contrast (50% is default/1.0)
    float contrast = 1.1;

    // 3. Brightness (50% is default/0.0)
    // Increases the "whiteness" of blacks, just like the NVIDIA slider.
    float brightness = 0.0;

    // 4. Gamma (1.00 is default)
    float gamma = 1.0;

    // 5. Hue (0 is default)
    // Usually kept at 0, so no variable needed.

    // --- ALGORITHM ---

    // Apply Vibrance
    vec3 luminanceCoeff = vec3(0.2126, 0.7152, 0.0722);
    float luminance = dot(color, luminanceCoeff);
    vec3 saturatedColor = mix(vec3(luminance), color, 1.0 + vibrance);

    // Apply Contrast
    vec3 contrastedColor = (saturatedColor - 0.5) * contrast + 0.5;

    // Apply Brightness (Digital Lift)
    vec3 brightColor = contrastedColor + brightness;

    // Apply Gamma
    vec3 finalColor = pow(brightColor, vec3(1.0 / gamma));

    fragColor = vec4(finalColor, pixColor.a);
}
EOF

echo "✔ Shader installed: $SHADER_FILE"

# Ensure command exists at the TOP of config
if ! grep -Fxq "$COMMAND" "$HYPR_CONF"; then
    sed -i "1s|^|$COMMAND\n|" "$HYPR_CONF"
    echo "✔ Command added to top of hyprland.conf"
else
    echo "ℹ Command already present, skipping insert"
fi

# Reload Hyprland if possible
if command -v hyprctl &> /dev/null; then
    hyprctl reload
    echo "✔ Hyprland reloaded"
fi

echo "🎉 Vibrance shader setup complete!"
