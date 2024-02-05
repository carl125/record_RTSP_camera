#!/bin/bash
temp_camera="/etc/record/temp/outdoor"
cam_stream_url="rtsp://username:password@ip-addr:port/cam/realmonitor?channel=1&subtype=0&unicast=true&proto=Onvif"
max_retries=3
retry_interval=2  # seconds

# Record for 95 seconds to the temporary directory with retry logic
for ((i=1; i<=max_retries; i++)); do
    # Update the timestamp for each attempt
    date_now=$(date +\%d-\%m-\%Y--\%H-\%M)

    echo "Attempt $i of $max_retries to record the stream..."
    sudo ffmpeg -i "$cam_stream_url" -vcodec copy -r 60 -t 65 -y "$temp_camera"/$date_now.mp4

    # Check if ffmpeg was successful
    if [ $? -eq 0 ]; then
        echo "yuh-s: Recording successful."
        break  # Exit the loop if recording was successful
    else
        echo "yuh-e: Recording failed. Server returned error. Retrying in $retry_interval seconds..."
        sleep $retry_interval
    fi
done

# If recording was not successful after retries, log an error
if [ $i -gt $max_retries ]; then
    echo "yuh-e: Recording failed after $max_retries attempts."
fi

