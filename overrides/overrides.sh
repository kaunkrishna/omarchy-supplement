#!/bin/bash

set -e

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_CONFIG="$SCRIPT_DIR/overrides/hyprland-overrides.lua"
SOURCE_LINE="dofile(\"$OVERRIDES_CONFIG\")"

# Check if Hyprland config exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Please install Hyprland first."
    exit 1
fi

# Check if overrides config exists
if [ ! -f "$OVERRIDES_CONFIG" ]; then
    echo "Overrides config not found at $OVERRIDES_CONFIG"
    exit 1
fi

# Add overrides if not already loaded
if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Hyprland overrides are already loaded."
else
    echo "Adding Hyprland overrides..."

    echo "" >> "$HYPRLAND_CONFIG"
    echo "-- Overrides from omarchy-supplement" >> "$HYPRLAND_CONFIG"
    echo "$SOURCE_LINE" >> "$HYPRLAND_CONFIG"

    echo "Hyprland overrides added successfully."
fi

echo "Overrides setup completed!"
