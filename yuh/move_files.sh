#!/bin/bash

# Directories for each camera
kitchen_dir="/etc/record/camera/kitchen"
living_room_dir="/etc/record/camera/living_room"
outdoor_dir="/etc/record/camera/outdoor"

# Temporary directories for each camera
temp_kitchen="/etc/record/temp/kitchen"
temp_living_room="/etc/record/temp/living_room"
temp_outdoor="/etc/record/temp/outdoor"

# Function to move files
move_files () {
    local source_dir=$1
    local target_dir=$2

    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            current_time=$(date +%s)
            last_mod_time=$(stat -c %Y "$file")
            file_age=$((current_time - last_mod_time))

            echo "File $file (last_mod_time: $last_mod_time - file_age: $file_age)"

            if [ "$file_age" -gt 120 ]; then
                mv "$file" "$target_dir"
            else
                echo "File $file is still too recent or may still be written to."
            fi
        fi
    done
}

# Move files for each camera
move_files "$temp_kitchen" "$kitchen_dir"
move_files "$temp_living_room" "$living_room_dir"
move_files "$temp_outdoor" "$outdoor_dir"
