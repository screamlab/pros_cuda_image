FROM ghcr.io/screamlab/pros_base_image:latest
ENV ROS2_WS /workspaces
ENV ROS_DOMAIN_ID=1
ENV ROS_DISTRO=humble
ARG THREADS=4
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

##### Copy Source Code #####
COPY . /tmp

##### Environment Settings #####
WORKDIR /tmp

# System Upgrade
RUN apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt autoclean -y && \

    pip3 install --no-cache-dir --upgrade pip && \

    ##### Install cuda 12.4 and cudnn #####
    axel -q -n 10 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt update && \
    apt install -y cuda-toolkit-12-4 cudnn-cuda-12 && \

    ##### Install pip requirements #####
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \

    ##### Install TensorRT 10.4 GA #####
    axel -q -n 10 https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.4.0/local_repo/nv-tensorrt-local-repo-ubuntu2204-10.4.0-cuda-12.6_1.0-1_amd64.deb && \
    dpkg -i nv-tensorrt-local-repo-ubuntu2204-10.4.0-cuda-12.6_1.0-1_amd64.deb && \
    cp /var/nv-tensorrt-local-repo-ubuntu2204-10.4.0-cuda-12.6/*-keyring.gpg /usr/share/keyrings/ && \
    apt update && \
    apt install -y tensorrt python3-libnvinfer-dev && \

    # Verify Installation
    dpkg-query -W tensorrt && \

    ##### Post-Settings #####
    # Clear tmp and cache
    rm -rf /tmp/* && \
    rm -rf /temp/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${ROS2_WS}
ENTRYPOINT [ "/ros_entrypoint.bash" ]
CMD ["bash", "-l"]
