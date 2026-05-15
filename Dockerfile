# ─────────────────────────────────────────────────────────────
#  RunPod Template: ComfyUI + JupyterLab
# ─────────────────────────────────────────────────────────────
FROM runpod/pytorch:2.1.0-py3.10-cuda12.0.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PORT=8188
ENV JUPYTER_PORT=8888

WORKDIR /workspace

# ── System deps ───────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg aria2 \
    libgl1 libglib2.0-0 libsm6 libxrender1 libxext6 \
    libopencv-dev python3-opencv \
    nodejs npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Python deps ───────────────────────────────────────────────
RUN pip install --no-cache-dir --upgrade pip

RUN pip install --no-cache-dir \
        torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cu121

RUN pip install --no-cache-dir \
        jupyterlab ipywidgets \
        xformers \
        transformers accelerate diffusers \
        safetensors einops omegaconf tqdm \
        Pillow opencv-python scipy numpy \
        onnxruntime-gpu \
        ultralytics \
        segment-anything \
        imageio imageio-ffmpeg \
        colour-science

# ── Clone ComfyUI ─────────────────────────────────────────────
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    cd /workspace/ComfyUI && \
    git checkout 52976f3e && \
    pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt

# ── ComfyUI Manager ───────────────────────────────────────────
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt

# ── Custom nodes ──────────────────────────────────────────────
RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    /workspace/ComfyUI/custom_nodes/rgthree-comfy || true

RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes || true

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use || true

RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes || true

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack || true

RUN git clone https://github.com/city96/ComfyUI-GGUF.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF || true

# ── Install custom node requirements ──────────────────────────
RUN find /workspace/ComfyUI/custom_nodes -name requirements.txt \
    -exec pip install --no-cache-dir -r {} \; || true

# ── Copy startup scripts ──────────────────────────────────────
COPY start.sh /start.sh
COPY download_models.sh /download_models.sh

RUN chmod +x /start.sh /download_models.sh

EXPOSE 8188
EXPOSE 8888

CMD ["/start.sh"]
