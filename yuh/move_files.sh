#!/bin/bash

# Define the source (temporary) and destination directories
temp_camera="/etc/record/temp"
directory="/etc/record/camera"
date_today=$(date +\%d-\%m-\%Y)
path_today="$directory/$date_today"

# Move the completed recordings to the sync directory
# This assumes that the files are named with their completion timestamp
for file in "$temp_camera"/*; do
    if [ -f "$file" ]; then
        # Get the current time and the last modification time of the file
        current_time=$(date +%s)
        last_mod_time=$(stat -c %Y "$file")

        # Calculate the age of the file in seconds
        file_age=$((current_time - last_mod_time))
        echo "File $file (last_mod_time: $last_mod_time - file_age: $file_age)"

        # If the file is older than a threshold (e.g., 120 seconds), it is assumed to be complete
        if [ "$file_age" -gt 120 ]; then
            mv "$file" "$path_today"
        else
            echo "File $file is still too recent or may still be written to."
        fi
    fi
done
