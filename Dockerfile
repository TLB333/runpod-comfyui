FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ── System packages ────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git git-lfs vim libgl1 libglib2.0-0 libsm6 \
    libxext6 libxrender-dev ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# ── Python packages ────────────────────────────────────────────
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        jupyterlab ipywidgets \
        xformers \
        transformers accelerate diffusers \
        safetensors einops omegaconf tqdm \
        Pillow opencv-python-headless scipy numpy \
        onnxruntime-gpu \
        ultralytics \
        segment-anything \
        imageio imageio-ffmpeg \
        colour-science \
        piexif \
        gdown

# ── ComfyUI ────────────────────────────────────────────────────
ARG CACHEBUST=1
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt

# ── Custom Nodes ───────────────────────────────────────────────
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt

RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    /workspace/ComfyUI/custom_nodes/rgthree-comfy && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/rgthree-comfy/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    pip install --no-cache-dir \
        piexif \
        opencv-python-headless \
        pycocotools \
        scikit-image \
        watchdog 2>/dev/null || true

RUN git clone https://github.com/city96/ComfyUI-GGUF.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/ainvfx/ComfyUI-SeedVR2_VideoUpscaler.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/spacepxl/ComfyUI-Image-Filters.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Image-Filters && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Image-Filters/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/cubiq/ComfyUI_essentials.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_essentials && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI_essentials/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git \
    /workspace/ComfyUI/custom_nodes/was-node-suite-comfyui && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/was-node-suite-comfyui/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack && \
    python install.py 2>/dev/null || true && \
    pip install --no-cache-dir -r requirements.txt 2>/dev/null || true

RUN git clone https://github.com/ClownsharkBatwing/RES4LYF.git \
    /workspace/ComfyUI/custom_nodes/RES4LYF && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/RES4LYF/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git \
    /workspace/ComfyUI/custom_nodes/comfyui-vrgamedevgirl && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/comfyui-vrgamedevgirl/requirements.txt 2>/dev/null || true

# ── Model directories ──────────────────────────────────────────
RUN mkdir -p \
    /workspace/ComfyUI/models/diffusion_models \
    /workspace/ComfyUI/models/text_encoders \
    /workspace/ComfyUI/models/vae \
    /workspace/ComfyUI/models/loras \
    /workspace/ComfyUI/models/ultralytics/bbox \
    /workspace/ComfyUI/models/sams \
    /workspace/ComfyUI/models/seedvr2 \
    /workspace/ComfyUI/user/default/workflows

# ── Copy files ─────────────────────────────────────────────────
COPY workflows/ /workspace/ComfyUI/user/default/workflows/
COPY loras/ /workspace/ComfyUI/models/loras/
COPY ultralytics/ /workspace/ComfyUI/models/ultralytics/
COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN touch /download_models.sh && chmod +x /download_models.sh

EXPOSE 8188 8888
ENTRYPOINT ["/start.sh"]
