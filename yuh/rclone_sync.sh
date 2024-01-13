#!/bin/bash

# Define the directory for recordings
directory="/etc/record/camera"
date_today=$(date +\%d-\%m-\%Y)
path_today="$directory/$date_today"

# Sync all recent files (e.g., from the last hour)
rclone copy "$path_today" gg-drive:camera/"$date_today" --max-age 1h &

# Get the PID of the rclone process
RCLONE_PID=$!

# Wait for the rclone copy process to complete
wait $RCLONE_PID
RCLONE_STATUS=$?

# Check if rclone copy was successful
if [ $RCLONE_STATUS -eq 0 ]; then
    echo "Sync successful. Deleting local recent files..."
    find "$path_today" -type f -newermt "1 hour ago" -exec rm -f {} \;
else
    echo "Sync failed. Local recent files retained."
fi
