#!/bin/bash

# Base directory for camera recordings
base_directory="/etc/record/camera"

# Camera directories and their respective cloud destinations
declare -A camera_cloud_map
camera_cloud_map["kitchen"]="one-drive:camera/kitchen"
camera_cloud_map["living_room"]="one-drive2:camera/living_room"
camera_cloud_map["outdoor"]="one-drive3:camera/outdoor"

declare -a pids
declare -A pid_file_map

# Function to handle the upload process for each camera directory
upload_camera_dir() {
    local camera_dir=$1
    local cloud_dir=${camera_cloud_map[$camera_dir]}

    for file in "$base_directory/$camera_dir"/*; do
        if [ -f "$file" ]; then
            # Extract the date from the file name
            file_date=$(basename "$file" | awk -F '--' '{print $1}')

            # Start rclone copy in the background and save its PID
            rclone copy "$file" "$cloud_dir"/"$file_date" &
            pid=$!
            pids+=($pid)
            pid_file_map[$pid]=$file
        fi
    done
}

# Iterate over each camera directory and upload files
for dir in "${!camera_cloud_map[@]}"; do
    upload_camera_dir "$dir"
done

# Wait for all rclone processes to complete
for pid in "${pids[@]}"; do
    wait $pid
    RCLONE_STATUS=$?
    if [ $RCLONE_STATUS -eq 0 ]; then
        echo "yuh-s: Sync successful for process $pid."
        file=${pid_file_map[$pid]}
        echo "yuh-s: Deleting local file: $file"
        rm -f "$file"
    else
        echo "yuh-e: Sync failed for process $pid."
    fi
done
