#!/bin/bash
temp_camera="/etc/record/temp/outdoor"
date_now=$(date +\%d-\%m-\%Y--\%H-\%M)
cam_stream_url=http://77.222.181.11:8080/mjpg/video.mjpg

# Record for 55 second to the temporary directory
sudo ffmpeg -i "$cam_stream_url" -vcodec copy -t 55 -y "$temp_camera"/$date_now.mp4

