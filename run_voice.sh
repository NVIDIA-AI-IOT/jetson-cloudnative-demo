#!/usr/bin/env bash

CONTAINER_IMAGE="nvcr.io/nvidia/jetson-voice:jetpack_4.4_DP"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

show_help() {
    echo " "
    echo "usage: Starts the Docker container in interactive mode"
    echo " "
    echo "   ./scripts/docker_run_interactive.sh --container=<DOCKER_IMAGE>"
    echo " "
    echo "args:"
    echo " "
    echo "   --help                         show this help text and quit"
    echo " "
    echo "   -c, --container=<DOCKER_IMAGE> specifies the name of the Docker container"
    echo "                                  image to use (default: 'jetson-voice')"
    echo " "
}

die() {
    printf '%s\n' "$1"
    show_help
    exit 1
}

# parse arguments
while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -c|--container)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                CONTAINER_IMAGE=$2
                shift
            else
                die 'ERROR: "--container" requires a non-empty option argument.'
            fi
            ;;
        --container=?*)
            CONTAINER_IMAGE=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --container=)         # Handle the case of an empty --image=
            die 'ERROR: "--container" requires a non-empty option argument.'
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

sudo nvpmodel -m 2
sudo jetson_clocks
xhost +

# run the container
sudo xhost +si:localuser:root

sudo docker run -d --runtime nvidia -it --rm --network host -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    --device /dev/bus/usb --device /dev/snd --cpuset-cpus=0 \
    -v $ROOT_DIR/TestPassages/:/workspace/TestPassages \
    $CONTAINER_IMAGE \
    python3 src/chatbot.py --mic 24 --push-to-talk space --para /workspace/TestPassages

#sudo docker run --runtime nvidia -it --rm --network host -e DISPLAY=$DISPLAY \
#    -v /tmp/.X11-unix/:/tmp/.X11-unix \
#    --device /dev/bus/usb --device /dev/snd \
#    -v /home/nvidia/nvme/ReviewerResource/Demo/MultiContainer/TestPassages/:/workspace/TestPassages \
#    $CONTAINER_IMAGE \
#    python3 src/chatbot.py --mic 24 --push-to-talk space --para /workspace/TestPassages


# start the container (if it isn't already running)
#sudo docker start $CONTAINER_NAME

# attach to the container, interactive mode
#sudo docker exec -it $CONTAINER_NAME /bin/bash



#
# example commands:
#
#   python3 src/test_nlp.py --para test/gtc.txt
#   python3 src/test_asr.py --wav test/dusty.wav
#
#   ./scripts/list_microphones.sh
#
#Input Device ID 4 - jetson-xaviernx-ape: - (hw:1,0) (inputs=16) (sample_rate=44100)
#Input Device ID 5 - jetson-xaviernx-ape: - (hw:1,1) (inputs=16) (sample_rate=44100)
#Input Device ID 6 - jetson-xaviernx-ape: - (hw:1,2) (inputs=16) (sample_rate=44100)
#Input Device ID 7 - jetson-xaviernx-ape: - (hw:1,3) (inputs=16) (sample_rate=44100)
#Input Device ID 8 - jetson-xaviernx-ape: - (hw:1,4) (inputs=16) (sample_rate=44100)
#Input Device ID 9 - jetson-xaviernx-ape: - (hw:1,5) (inputs=16) (sample_rate=44100)
#Input Device ID 10 - jetson-xaviernx-ape: - (hw:1,6) (inputs=16) (sample_rate=44100)
#Input Device ID 11 - jetson-xaviernx-ape: - (hw:1,7) (inputs=16) (sample_rate=44100)
#Input Device ID 12 - jetson-xaviernx-ape: - (hw:1,8) (inputs=16) (sample_rate=44100)
#Input Device ID 13 - jetson-xaviernx-ape: - (hw:1,9) (inputs=16) (sample_rate=44100)
#Input Device ID 14 - jetson-xaviernx-ape: - (hw:1,10) (inputs=16) (sample_rate=44100)
#Input Device ID 15 - jetson-xaviernx-ape: - (hw:1,11) (inputs=16) (sample_rate=44100)
#Input Device ID 16 - jetson-xaviernx-ape: - (hw:1,12) (inputs=16) (sample_rate=44100)
#Input Device ID 17 - jetson-xaviernx-ape: - (hw:1,13) (inputs=16) (sample_rate=44100)
#Input Device ID 18 - jetson-xaviernx-ape: - (hw:1,14) (inputs=16) (sample_rate=44100)
#Input Device ID 19 - jetson-xaviernx-ape: - (hw:1,15) (inputs=16) (sample_rate=44100)
#Input Device ID 20 - jetson-xaviernx-ape: - (hw:1,16) (inputs=16) (sample_rate=44100)
#Input Device ID 21 - jetson-xaviernx-ape: - (hw:1,17) (inputs=16) (sample_rate=44100)
#Input Device ID 22 - jetson-xaviernx-ape: - (hw:1,18) (inputs=16) (sample_rate=44100)
#Input Device ID 23 - jetson-xaviernx-ape: - (hw:1,19) (inputs=16) (sample_rate=44100)
#Input Device ID 24 - Logitech H570e Mono: USB Audio (hw:2,0) (inputs=2) (sample_rate=44100)
#
#   python3 src/test_asr.py --mic 24
#       (press Enter to start recording, and enter again to exit)
#
#   python3 src/chat_interactive.py --para test/gtc.txt --mic 24
#

