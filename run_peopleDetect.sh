#!/usr/bin/env bash

CONTAINER=nvcr.io/nvidia/deepstream-peopledetection:r32.4.2

sudo nvpmodel -m 2
sudo jetson_clocks
xhost +

sudo sh -c 'echo 850000000 > /sys/kernel/debug/bpmp/debug/clk/nafll_dla/rate'

sudo docker run -d -it --rm --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix $CONTAINER  deepstream-test5-app -c deepstream-5.0/samples/configs/deepstream-app/sourceX_1080p_dec_infer-resnet_tracker_tiled_display_int8_hq_dla_nx.txt

