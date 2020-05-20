# Cloud-Native Demo on Jetson
![Cloud-Native Demo](docs/demo.jpg)
The NVIDIA Jetson platform supports cloud-native technologies and workflows such as containerization and orchestration. This support enables application development, deployment and management at scale, which is essential to deliver AI at the edge to millions of devices. 

This demo is built around example AI applications for a service robot use case. It was created specifically to showcase the capabilities of Jetson Xavier NX. (The complete demo will also run on Jetson AGX Xavier, but not other Jetsons, as some parts leverage Tensor cores not present in other Jetsons.)

Service robots are autonomous robots that need to interact with people in retail, hospitality, healthcare, warehouse, and other settings.  For example, consider a customer service robot in a retail setting, interacting with customers and providing helpful answers to customer queries. Such a robot will need to perform the following tasks:

-   Identify humans
-   Detect when a customer is talking to the robot
-   Understand where a customer is pointing to while interacting with the robot
-   Understand what a customer is asking
-   Provide useful answers

Hence the robot will need multiple AI models such as:

-   People identification to identify humans
-   Gaze detection to detect when a customer is talking to the robot (as opposed to someone else)
-   Pose detection to detect customer’s pose
-   Speech recognition to detect words in sentences spoken by the customer
-   Natural language processing to understand the sentence, including context, to provide relevant answers back to the customer.
    

Following the cloud-native approach to application development, these individual models can be developed independently. Once an individual model is developed, it can be containerized with all dependencies included, and deployed to any Jetson device.

For this demo we have developed and containerized the models, which are hosted on [NVIDIA NGC](https://www.nvidia.com/en-us/gpu-cloud/). This demo runs seven models simultaneously as described below:
- [DeepStream Container with people detection](https://ngc.nvidia.com/catalog/containers/nvidia:deepstream-peopledetection)
  	- Resnet-18 model with input image size of 960X544X3. The model was converted from TensorFlow to TensorRT.
- [Pose container with pose detection](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-pose)
  	- Resnet-18 model with input image resolution of 224X224. The model was converted from PyTorch to TensorRT.
- [Gaze container with gaze detection](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-gaze)
   - MTCNN model for face detection with input image resolution of 260X135. The model was converted from Caffe to TensorRT.
  - NVIDIA Facial landmarks model with input resolution of 80X80 per face. The model was converted from TensorFlow to TensorRT.
  - NVIDIA Gaze model with input resolution of 224X224 per left eye, right eye and whole face. The model was converted from TensorFlow to TensorRT.
- [Voice container with speech recognition and Natural Language Processing](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-voice)
   - Quartznet-15X5 model for speech recognition which was converted from PyTorch to TensorRT. 
  - BERT Base/Large models for language model for NLP which were converted from TensorFlow to TensorRT.

These containers provide the building blocks of a service robot use case. Modifying applications and deploying updates is easy because of containerization. Other containers won't be affected by updates, giving zero down time and a seamless experience.

### Running the individual demo containers

To run the demo containers individually, refer to the corresponding instructions at each container's NGC page:

-   [DeepStream container with people detection](https://ngc.nvidia.com/catalog/containers/nvidia:deepstream-peopledetection)    
-   [Pose container with pose detection](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-pose)
-   [Gaze container with gaze detection](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-gaze)
-   [Voice container with speech recognition and Natural Language Processing](https://ngc.nvidia.com/catalog/containers/nvidia:jetson-voice)

### Running the Cloud-Native Demo

This demo requires two items in addition to a Jetson Xavier NX Developer Kit: 1) an M.2 NVMe drive, and 2) a USB Headset with microphone such as Logitech H110 or H390.

#### Why is NVMe Required for this Demo?

Since these demo containers are not yet fully optimized for storage and memory size, this demo requires NVMe for extra storage and adding swap space for extra virtual memory. The usual path for deploying containers into production involves optimization for size and memory usage. These demo containers have not yet gone through such optimizations.

#### Instructions to Set up NVMe Drive

The NVMe drive can be connected to the M.2 connector underneath the Jetson Xavier NX Developer Kit. Power down the developer kit and then connect the NVMe as shown in this picture:
![Connecting NVME](docs/nvme.jpg)

Boot the developer kit, Format the NVMe, prepare the mount point, and then mount the NVMe.  NOTE that these examples and following refer to `/home/nvidia`, but you should replace with path to your home directory.

``` bash
sudo mkfs.ext4 /dev/nvme0n1
sudo mkdir /home/nvidia/nvme
sudo mount /dev/nvme0n1 /home/nvidia/nvme
```
Once the NVMe is mounted, add the following to /etc/fstab and then reboot the developer kit. the NVMe storage will be automounted going forward.

``` bash
/dev/nvme0n1 /home/nvidia/nvme ext4 defaults 0 1
```


Next, change the docker registry to point to NVMe so that the docker images are stored in NVMe.  NOTE that the second command below is optional unless you have previously pulled some containers, in which case it is required to move those docker images to NVMe:

``` bash
sudo mkdir /home/nvidia/nvme/docker
sudo mv /var/lib/docker/* /home/nvidia/nvme/docker/.
sudo ln -s /home/nvidia/nvme/docker /var/lib/docker
```

Next, create a file swap on NVMe by following these instructions:

​	Turn off zram:

``` bash
cd /etc/systemd
sudo mv nvzramconfig.sh nvzramconfig.sh.orig
sudo reboot
```

​	Add swap file on nvme and verify:

``` bash
sudo fallocate -l 32G /home/nvidia/nvme/swapfile
sudo chmod 600 /home/nvidia/nvme/swapfile
sudo mkswap /home/nvidia/nvme/swapfile
sudo swapon /home/nvidia/nvme/swapfile
sudo swapon -s
```


Add the line below to /etc/fstab so swap file will be automounted going forward:

``` bash
/home/nvidia/nvme/swapfile swap swap defaults 0 0
```

Reboot the developer kit after saving the /etc/fstab changes.

#### Pulling the Containers

Pull the 4 demo containers using the pull instruction mentioned in each container’s NGC page.

#### Running the Demo

First clone this repository:  
``` bash
git clone https://github.com/NVIDIA-AI-IOT/jetson-cloudnative-demo
```

Install the xdotool app by running the  command below:
``` bash
sudo apt-get install xdotool
```

Go to the directory
``` bash
cd jetson-cloudnative-demo
```

Launch the demo
``` bash  
sudo ./run_demo.sh
```

-   The script will ask you to ensure that the USB Headset with Mic is connected. Once you make sure it is connected, please hit the Enter key.
-   The script will take approximately two and half minutes to launch all four containers and begin running the concurrent inference workloads.
    -   We recommend that you CLOSE all other applications (e.g, Chrome browser, Word document, etc.) before starting the demo, and that you do not interact with the containers during the launch process. The launch process is memory intensive and interactions may cause further slowdown. These containers were created for demo purpose only and (unlike real-world applications) are not optimized for memory and system resource usage.
-   When all four containers are successfully loaded, you can now start interacting with the demo.

Top Left Quadrant - People Detection Container

The top left quadrant of the demo is running a containerized people detection inferencing task using NVIDIA DeepStream. It is analyzing four concurrent video streams to identify the number of people in each stream.

Top Right Quadrant - Natural Language Processing Container

The top right quadrant of the demo is running a containerized Natural Language Processing (NLP) demo using the demanding BERT NLP neural network. This demo takes your questions through voice input on specific topics and provides relevant answers based on the content available under each topic. Please follow these instructions to experience this part of the demo:

1.  Select one of the several available topics by using the left/right arrow key on your keyboard.
2.  Read the content of each topic to come up with a question.
3.  Press the ‘space’ key on the keyboard and keep it pressed while asking your question (clearly, and with good volume) into the headset microphone. For example, under the topic titled GTC, you may want to ask questions such as “What is GTC?” or “Who is presenting the keynote”, “At what time is the keynote?” and other such questions. If relevant information is available in the content for your question, then the NLP network will provide a text answer that is shown on the screen. NOTE that the very first question may take a couple of seconds to register.
4.  You can also create your own topic, add your content and ask questions on that content using the “New” topic menu item.
5.  These neural networks have been trained but are not finely optimized like commercial assistants such as Google Assistant or Alexa. These are provided only for demo purposes to convey that Jetson Xavier NX is capable of running multiple networks concurrently while delivering real-time performance. Much more time would be spent fine-tuning the neural network performance for a commercial application.
    

Bottom Left Quadrant - Pose Estimation

This container is running a pose estimation neural network to estimate the pose of people in the input video stream. For example, this information could be used by a retail service robot to figure out whether the person is pointing at a specific product in the store, or asking a delivery robot to stop based on the pose of the person’s hands, etc.

Bottom Right Quadrant - Gaze Estimation

This container is running a gaze estimation neural network to figure out whether the person in the frame is looking at the robot or looking somewhere else. Whenever the person looks at the robot, the boxes around the person’s eyes turn green. This information could be used to help the robot know when to interacting with the person.

To end the demo, please go back to the terminal window by clicking on the terminal icon on the left side of your screen and hit “Enter” to close all containers.

