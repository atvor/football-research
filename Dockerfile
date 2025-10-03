# ==== BASE IMAGE ====
# For GPU support we use NVIDIA CUDA devel (Ubuntu 20.04)
ARG DOCKER_BASE=nvidia/cuda:11.8.0-devel-ubuntu20.04
FROM ${DOCKER_BASE}
ARG DEBIAN_FRONTEND=noninteractive

# ==== SYSTEM DEPENDENCIES ====
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    git build-essential cmake \
    libgl1-mesa-dev mesa-utils \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-gfx-dev \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# ==== FIX pip/setuptools/wheel/packaging ====
# gym==0.21.0 has broken metadata ("opencv-python>=3.") that only works
# with older packaging toolchain versions
RUN python3 -m pip install --upgrade "pip==23.0.1" \
    "setuptools==59.8.0" \
    "wheel==0.37.1" \
    "packaging==20.9"

# ==== INSTALL GYM 0.21 ====
RUN python3 -m pip install "gym==0.21.0"

# ==== EXTRA DEPENDENCIES ====
# gfootball imports `six`, plus needs numpy, pygame, opencv
RUN python3 -m pip install "six==1.16.0" "numpy<1.25" "pygame>=1.9.6" "opencv-python"

# ==== GOOGLE FOOTBALL ====
WORKDIR /gfootball
COPY . /gfootball
RUN python3 -m pip install .

# ==== OPTIONAL: Install PyTorch for training agents ====
# Uncomment if you want to run RL training inside the container
# RUN python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# ==== DEFAULT CMD ====
# Headless mode (render=False) runs faster and is usually used for RL training
CMD ["python3","-m","gfootball.play_game","--action_set=full","--render=False"]
