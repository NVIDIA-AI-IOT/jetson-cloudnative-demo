#!/usr/bin/env bash

CONTAINER=nvcr.io/nvidia/jetson-gaze:r32.4.2

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HOST_VIDEO_DIR="$ROOT_DIR/Videos"
HOST_VIDEO_NAME=
VIDEO=/videos/gaze_video.mp4
#VIDEO=/userVideos/$HOST_VIDEO_NAME

echo Running gaze

sudo nvpmodel -m 2
sudo jetson_clocks
xhost +

sudo xhost +si:localuser:root
sudo docker run -d --runtime nvidia -it --rm --network host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix  -v $HOST_VIDEO_DIR:/userVideos/ --cpuset-cpus=1 $CONTAINER python3 run_gaze_sequential.py $VIDEO --loop --codec=h264
