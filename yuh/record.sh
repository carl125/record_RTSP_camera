#!/bin/bash
directory="/etc/record/camera"
temp_camera="/etc/record/temp"
date_now=$(date +\%d-\%m-\%Y--\%H-\%M)
path="$directory/$(date +\%d-\%m-\%Y)"

# Check if the directory exists
if [ ! -d "$path" ]; then
    # If the directory does not exist, create it
    mkdir -p "$path"
    echo "Directory created: $path"
else
    echo "Directory already exists: $path"
fi


# Record to the temporary directory
sudo ffmpeg -i http://webcam.mchcares.com/mjpg/video.mjpg -vcodec copy -t 58 -y "$temp_camera"/$date_now.mp4
