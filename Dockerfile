FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# -------------------------
# 1. System dependencies (minimal, headless)
# -------------------------
RUN apt-get update && apt-get install -y wget tar xz-utils sudo software-properties-common libgl1 libglib2.0-0 libxrender1 libxrandr2 libxinerama1 libxcursor1 libxi6 libxinerama1 libxcursor1 libxi6 


# -------------------------
# 2. Create non-root user for CARLA
# -------------------------
RUN useradd -m -s /bin/bash carlauser && \
    echo "carlauser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# -------------------------
# 3. Install Python 3.7 (CARLA Python API requirement)
# -------------------------
RUN apt update && \
    apt install -y \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    ca-certificates


# -------------------------
# 4. Download and extract CARLA 0.9.15
# -------------------------

RUN mkdir -p /workspace/carla && \
    cd /workspace/carla && \
    wget https://tiny.carla.org/carla-0-9-15-linux && \
    tar -xf carla-0-9-15-linux && \
    rm carla-0-9-15-linux

# -------------------------
# 5. Setup CARLA Python 3.7 virtual environment
# -------------------------
RUN python3.10 -m venv /workspace/carla/env && \
    /workspace/carla/env/bin/pip install --upgrade pip setuptools wheel && \
    /workspace/carla/env/bin/pip install \
        /workspace/carla/PythonAPI/carla/dist/carla*cp37*.whl && \
    /workspace/carla/env/bin/pip install \
        -r /workspace/carla/PythonAPI/carla/requirements.txt

# -------------------------
# 6. Permissions
# -------------------------
RUN chown -R carlauser:carlauser /workspace


# -------------------------
# 7. Default shell (no auto-start)
# -------------------------
USER root
CMD ["/bin/bash"]
