# ─────────────────────────────────────────────────────────────
#  RunPod Template: ComfyUI + JupyterLab
#  Workflows: CarouselPosechanger, Flux Background Change,
#             Img2Img Upscaler FLUX, TEXTGen
#  Base: RunPod PyTorch 2.1 · CUDA 12.1 · Ubuntu 22.04
# ─────────────────────────────────────────────────────────────
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PORT=8188
ENV JUPYTER_PORT=8888

WORKDIR /workspace

# ── System deps ───────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg \
    libgl1 libglib2.0-0 libsm6 libxrender1 libxext6 \
    libopencv-dev python3-opencv \
    nodejs npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Python deps ───────────────────────────────────────────────
# Step 1: upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Step 2: PyTorch stack (must use its own index-url alone)
RUN pip install --no-cache-dir \
        torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cu124

# Step 3: everything else from PyPI
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
    pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt

# ── ComfyUI Manager ───────────────────────────────────────────
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt

# ── Custom nodes ──────────────────────────────────────────────

# rgthree — Any Switch, Image Comparer, Fast Groups Bypasser, Label, Mute/Bypass, Lora Loader Stack
RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    /workspace/ComfyUI/custom_nodes/rgthree-comfy && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/rgthree-comfy/requirements.txt 2>/dev/null || true

# KJNodes — PathchSageAttentionKJ, LazySwitchKJ, FluxKVCache
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes/requirements.txt 2>/dev/null || true

# ComfyUI-Easy-Use — easy * nodes
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use/requirements.txt 2>/dev/null || true

# ComfyUI_Comfyroll — CR Prompt List
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes/requirements.txt 2>/dev/null || true

# Impact Pack — FaceDetailer, SAMLoader, UltralyticsDetectorProvider
# Skip SAM2 compile — Impact Pack installs it at first run via ComfyUI Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    pip install --no-cache-dir \
        opencv-python-headless \
        pycocotools \
        scikit-image \
        watchdog 2>/dev/null || true

# Clownsampler — ClownsharKSampler_Beta, SharkChainsampler_Beta, BetaSamplingScheduler
RUN git clone https://github.com/Clownfish-s-swimming-pool/ComfyUI-clownsampler.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-clownsampler && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-clownsampler/requirements.txt 2>/dev/null || true

# ReferenceLatent — ReferenceLatent node
RUN git clone https://github.com/antpixel/ComfyUI-ReferenceLatent.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-ReferenceLatent 2>/dev/null || \
    git clone https://github.com/antphantompixel/ComfyUI-ReferenceLatent.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-ReferenceLatent || true

# ComfyUI-GGUF — EmptyFlux2LatentImage, Flux2Scheduler
RUN git clone https://github.com/city96/ComfyUI-GGUF.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF/requirements.txt 2>/dev/null || true

# SeedVR2 — SeedVR2LoadDiTModel, SeedVR2LoadVAEModel, SeedVR2VideoUpscaler
RUN git clone https://github.com/ainvfx/ComfyUI-SeedVR2_VideoUpscaler.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler/requirements.txt 2>/dev/null || true

# Color Transfer — ColorTransfer node
RUN git clone https://github.com/yuvraj108c/ComfyUI-Color-Transfer.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Color-Transfer && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Color-Transfer/requirements.txt 2>/dev/null || true

# ComfyUI-Image-Filters — FastFilmGrain
RUN git clone https://github.com/spacepxl/ComfyUI-Image-Filters.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Image-Filters && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Image-Filters/requirements.txt 2>/dev/null || true

# ComfyUI_essentials — ImageResize+, ImageScaleToMaxDimension, ImageSharpen, GetImageSize
RUN git clone https://github.com/cubiq/ComfyUI_essentials.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_essentials && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI_essentials/requirements.txt 2>/dev/null || true

# WAS Node Suite — fallback for WAS-sourced nodes
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git \
    /workspace/ComfyUI/custom_nodes/was-node-suite-comfyui && \
    pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/was-node-suite-comfyui/requirements.txt 2>/dev/null || true

# ── Model directories ─────────────────────────────────────────
RUN mkdir -p \
    /workspace/ComfyUI/models/checkpoints \
    /workspace/ComfyUI/models/unet \
    /workspace/ComfyUI/models/clip \
    /workspace/ComfyUI/models/vae \
    /workspace/ComfyUI/models/loras \
    /workspace/ComfyUI/models/controlnet \
    /workspace/ComfyUI/models/upscale_models \
    /workspace/ComfyUI/models/ultralytics/bbox \
    /workspace/ComfyUI/models/ultralytics/segm \
    /workspace/ComfyUI/models/sams \
    /workspace/ComfyUI/models/seedvr2 \
    /workspace/ComfyUI/output \
    /workspace/ComfyUI/input

# Models downloaded at pod startup via start.sh

# ── Bake in workflows ─────────────────────────────────────────
RUN mkdir -p /workspace/ComfyUI/user/default/workflows
COPY workflows/ /workspace/ComfyUI/user/default/workflows/

# ── Bake in character LoRAs ───────────────────────────────────
# ~1.9 GB — copied directly into the model path so they appear
# in ComfyUI's LoRA picker immediately on first launch
COPY loras/ /workspace/ComfyUI/models/loras/

# -- Bake in ultralytics detector models (Eyeful_v2-Paired.pt -> bbox/)
COPY ultralytics/ /workspace/ComfyUI/models/ultralytics/

# ── Startup script ────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188 8888
CMD ["/start.sh"]
