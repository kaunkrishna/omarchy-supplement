#!/bin/bash

# ============================================================
# Lenovo LOQ - NVIDIA S0ix Suspend Fix
#
# This script:
#   1. Checks whether NVIDIA S0ix power management is enabled.
#   2. If it is already enabled, does nothing.
#   3. If disabled, makes sure the required NVIDIA option exists.
#   4. Rebuilds the initramfs.
#   5. Reboots the system so the new setting takes effect.
# ============================================================

# File containing NVIDIA module options
NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"

# NVIDIA GPU power-management status file
NVIDIA_POWER="/proc/driver/nvidia/gpus/0000:01:00.0/power"

# The option we need for S0ix
S0IX_OPTION="options nvidia NVreg_EnableS0ixPowerManagement=1"


# ------------------------------------------------------------
# Check NVIDIA S0ix status
# ------------------------------------------------------------

echo "Checking NVIDIA S0ix power management..."

if [ ! -f "$NVIDIA_POWER" ]; then
    echo "Error: NVIDIA power status file was not found."
    echo "Is the NVIDIA driver loaded?"
    exit 1
fi

# Look for the current S0ix status
S0IX_STATUS=$(grep "Status:" "$NVIDIA_POWER" | awk '{print $2}')


# ------------------------------------------------------------
# If S0ix is already enabled, do nothing
# ------------------------------------------------------------

if [ "$S0IX_STATUS" = "Enabled" ]; then
    echo "NVIDIA S0ix is already enabled."
    echo "Nothing to do."
    exit 0
fi


# ------------------------------------------------------------
# S0ix is disabled, so fix the configuration
# ------------------------------------------------------------

echo "NVIDIA S0ix is disabled."
echo "Applying the required configuration..."


# Create nvidia.conf if it does not exist
if [ ! -f "$NVIDIA_CONF" ]; then
    echo "$NVIDIA_CONF does not exist."
    echo "Creating it..."

    sudo sh -c "printf '%s\n' '$S0IX_OPTION' > '$NVIDIA_CONF'"

else
    # Check whether the S0ix option is already present.
    if sudo grep -Fxq "$S0IX_OPTION" "$NVIDIA_CONF"; then
        echo "S0ix option is already present in $NVIDIA_CONF."
        echo "No duplicate line will be added."
    else
        echo "S0ix option is missing."
        echo "Adding it to $NVIDIA_CONF..."

        sudo sh -c "printf '%s\n' '$S0IX_OPTION' >> '$NVIDIA_CONF'"
    fi
fi


# ------------------------------------------------------------
# Rebuild initramfs
#
# This is required because the NVIDIA module needs to load
# with the new option during boot.
# ------------------------------------------------------------

echo
echo "Rebuilding initramfs..."

if ! sudo mkinitcpio -P; then
    echo "Error: mkinitcpio failed."
    echo "The system will NOT reboot."
    exit 1
fi


# ------------------------------------------------------------
# Reboot so the NVIDIA module loads with the new setting
# ------------------------------------------------------------

echo
echo "Initramfs rebuilt successfully."
echo "Rebooting..."

sudo reboot
