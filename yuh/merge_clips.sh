#!/bin/bash

concat_dir="/etc/record/to_concatenate"
output_dir="/etc/record/camera"
camera_dirs=("kitchen" "living_room" "outdoor") # Add your actual directory names

declare -a pids
declare -A pid_file_map

# Function to concatenate clips for a specific camera directory
concat_clips() {
    local camera_dir=$1

    # Navigate to the directory containing clips to concatenate
    cd "$concat_dir/$camera_dir"

    # Check if there are mp4 files in the directory
    if ls *.mp4 1> /dev/null 2>&1; then
        # Generate a file list for ffmpeg
        ls *.mp4 | sort | while read -r file; do echo "file '$file'" >> mylist.txt; done

        # Extract the earliest and latest timestamps from the filenames
        earliest_file=$(ls *.mp4 | sort | head -n 1)
        latest_file=$(ls *.mp4 | sort | tail -n 1)
        start_date=$(echo $earliest_file | awk -F '--' '{print $1}')
        start_time=$(echo $earliest_file | awk -F '--' '{print $2}' | awk -F '.' '{print $1}')
        end_date=$(echo $latest_file | awk -F '--' '{print $1}')
        end_time=$(echo $latest_file | awk -F '--' '{print $2}' | awk -F '.' '{print $1}')

        # Define the output file name based on the earliest and latest timestamps
        if [ "$start_date" == "$end_date" ]; then
            # Same day
            output_file="${start_date}__${start_time}_to_${end_time}.mp4"
        else
            # Different days
            output_file="${start_date}__${start_time}_to_${end_date}__${end_time}.mp4"
        fi

        # Use ffmpeg to concatenate the video files listed in mylist.txt
        ffmpeg -f concat -safe 0 -i mylist.txt -c copy "$output_dir/$camera_dir/$output_file" &

        # Save the PID of the ffmpeg process
        pid=$!
        pids+=($pid)
        pid_file_map[$pid]="$camera_dir" # Map the PID to the camera directory

    else
        echo "No files to concatenate in $camera_dir"
    fi
}

# Concatenate clips for each camera
for dir in "${camera_dirs[@]}"; do
    concat_clips "$dir"
done

# Wait for all ffmpeg processes to complete
for pid in "${pids[@]}"; do
    wait $pid
    CONCAT_STATUS=$?
    if [ $CONCAT_STATUS -eq 0 ]; then
        echo "yuh-s: Concatenation successful for process $pid."

        # Remove the source files and list file after successful concatenation
        camera_dir=${pid_file_map[$pid]}
        rm -f "$concat_dir/$camera_dir/"*.mp4
        rm -f "$concat_dir/$camera_dir/mylist.txt"
    else
        echo "yuh-e: Concatenation failed for process $pid."
    fi
done

