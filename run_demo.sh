#!/bin/bash


clean_docker ()
{
  sudo docker stop $(sudo docker ps -a -q) >/dev/null 2>&1
# sudo docker rm $(sudo docker ps -a -q)
}

echo "This demo will launch 4 containerized models. It will take arround 2.5 minutes for the demo to fully launch."
echo "Please close all applications like web browser,etc, before launching this demo"

read -p "Press [Enter] after making sure that the USB Headset with mic is connected to Jetson Xavier NX Developer Kit and the mic input is enabled in Ubuntu sound settings"


#export DISPLAY=:0
xhost +

clean_docker
sudo nvpmodel -m 2 >/dev/null 2>&1
sudo jetson_clocks >/dev/null 2>&1

echo "Launching DeepStream Container"
./run_peopleDetect.sh >/dev/null 2>&1

ds_id=$(xdotool search --name "DeepStreamTest5App")

while [[ -z $ds_id ]]
do
  sleep 5
  ds_id=$(xdotool search --name "DeepStreamTest5App")
done
xdotool windowminimize $ds_id
sleep 2

echo "Launching TRTIS server"
./run_trtis.sh >/dev/null 2>&1
sleep 15

echo "Launching Voice Container"
./run_voice.sh >/dev/null 2>&1
sleep 5

echo "Launching Pose Container"
./run_pose.sh >/dev/null 2>&1
sleep 10

echo "Launching Gaze Container"
./run_gaze.sh >/dev/null 2>&1
sleep 2


bert_id=$(xdotool search --name "Chatbot")
while [[ -z $bert_id ]]
do
  sleep 5
  bert_id=$(xdotool search --name "Chatbot")
done
xdotool windowminimize $bert_id

pose_id=$(xdotool search --name "python3" | head -1)
while [[ -z $pose_id ]]
do
  sleep 5
  pose_id=$(xdotool search --name "python3" | head -1)
done
xdotool windowminimize $pose_id

#xdotool search --name "python3" > window_list
#gaze_id=$(grep -v -h $pose_id window_list)
gaze_id=$(xdotool search --name "python3" | grep -v $pose_id)
while [[ -z $gaze_id ]]
do
  sleep 5
  gaze_id=$(xdotool search --name "python3" | grep -v $pose_id)
  #xdotool search --name "python3" > window_list
  #gaze_id=$(grep -v -h $pose_id window_list)
done
#sudo rm -f window_list
xdotool windowminimize $gaze_id

echo "Firing up inference engines"

sleep 75

echo "Arranging windows ..."
xprop -id $ds_id -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"
xprop -id $bert_id -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"
xprop -id $pose_id -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"
xprop -id $gaze_id -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"

xdotool windowactivate --sync $pose_id
xdotool windowmove $pose_id 0 540

xdotool windowactivate --sync $gaze_id
xdotool windowmove $gaze_id 960 540

xdotool windowactivate --sync $ds_id
xdotool windowmove $ds_id 0 0

xdotool windowactivate --sync $bert_id
xdotool windowmove $bert_id 960 0

read -p "Press [Enter] key to exit and kill the demo"
clean_docker
sudo sh -c 'cat /sys/kernel/debug/bpmp/debug/clk/nafll_dla/ceil_rate > /sys/kernel/debug/bpmp/debug/clk/nafll_dla/rate'
