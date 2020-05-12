#!/usr/bin/env bash

CONTAINER_IMAGE="nvcr.io/nvidia/jetson-voice:r32.4.2"
ASR_MODEL="quartz"

show_help() {
    echo " "
    echo "usage: Starts the Docker container and TensorRT Inference Server"
    echo " "
    echo "   ./scripts/docker_run_trtis.sh --container=<DOCKER_IMAGE>"
    echo "                                 --asr-model=<quartz|jasper>"
    echo " "
    echo "args:"
    echo " "
    echo "   --help                         Show this help text and quit"
    echo " "
    echo "   -c, --container=<DOCKER_IMAGE> Specifies the name of the Docker container"
    echo "                                  image to use (default: 'jetson-voice')"
    echo " "
    echo "   --asr-model=<quartz|jasper>    Selects Automatic Speech Recognition model"
    echo "                                     valid options are:  quartz | quartz-v1 | jasper"
    echo "                                     default value is:   quartz"
    echo " "
}

die() {
    printf '\n%s\n' "$1"
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
        --asr-model)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                ASR_MODEL=$2
                shift
            else
                die 'ERROR: "--asr-model" requires a non-empty option argument.'
            fi
            ;;
        --asr-model=?*)
            ASR_MODEL=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --asr-model=)         # Handle the case of an empty --image=
            die 'ERROR: "--asr-model" requires a non-empty option argument.'
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

# validate ASR_MODEL
if [ "$ASR_MODEL" != "quartz" ] && [ "$ASR_MODEL" != "quartz-v1" ] && [ "$ASR_MODEL" != "jasper" ]; then
    die "ERROR: invalid option for --asr-model=$ASR_MODEL (must be 'quartz', 'quartz-v1', or 'jasper')"
fi

echo "Container:  $CONTAINER_IMAGE"
echo "ASR Model:  $ASR_MODEL"
echo " "

sudo nvpmodel -m 2
sudo jetson_clocks
xhost +

# run the container
sudo xhost +si:localuser:root

sudo docker run -d  --runtime nvidia -it --rm --network host -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    --device /dev/bus/usb --device /dev/snd \
    $CONTAINER_IMAGE \
    trtserver --model-control-mode=none --model-repository=models/repository/jasper-asr-streaming-vad/


