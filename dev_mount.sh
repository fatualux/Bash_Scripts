#!/bin/bash

usb_mount() {
    # Ask for sudo password
    sudo -v

    # List all block devices with more details for debugging
    echo "Debug: Listing all block devices with details"
    lsblk -a -o NAME,FSTYPE,LABEL,SIZE,TYPE,MOUNTPOINT
    echo

    # Filter for partitions and display for debugging
    echo "Debug: Listing partitions"
    PARTITIONS=$(lsblk -dpno NAME,TYPE | grep -E '/dev/sd[b-z][1-9] .*part')
    echo "$PARTITIONS"
    echo

    # If no partitions found, try listing whole disks
    if [ -z "$PARTITIONS" ]; then
        echo "No partitions found, listing whole disks."
        PARTITIONS=$(lsblk -dpno NAME,TYPE | grep -E '/dev/sd[b-z] .*disk')
        echo "$PARTITIONS"
        echo
    fi

    # Select partition or whole disk using fzf
    DEVICE=$(echo "$PARTITIONS" | awk '{print $1}' | fzf)
    echo "Debug: Selected device: $DEVICE"
    echo

    # Check if a device was selected
    if [ -n "$DEVICE" ]; then
        # Get the label of the partition
        LABEL=$(lsblk -no LABEL "$DEVICE" | sed 's/ /_/g')
        echo "Debug: Partition label: $LABEL"
        echo

        # Correctly identify the user
        USER_NAME=$(logname)
        echo "Debug: Detected user: $USER_NAME"
        echo

        # Create the mount point directory based on the label in the /mnt directory
        MOUNT_POINT="/mnt/$LABEL"
        echo "Debug: Mount point: $MOUNT_POINT"
        echo
        sudo mkdir -p "$MOUNT_POINT"

        # Attempt to mount the device with exFAT filesystem type
        if sudo mount -t exfat "$DEVICE" "$MOUNT_POINT"; then
            echo "Successfully mounted $DEVICE at $MOUNT_POINT"
        else
            echo "Failed to mount $DEVICE. Check dmesg for more information."
        fi
    else
        echo "No device selected"
    fi
}

# Call the function
usb_mount
