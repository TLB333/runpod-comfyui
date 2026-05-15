#!/bin/bash
set -e

echo "════════════════════════════════════════════════"
echo "  RunPod | ComfyUI + JupyterLab"
echo "  Workflows: Carousel, BG Change, Img2Img, Text"
echo "════════════════════════════════════════════════"

# Fix comfy_aimdo ModelMMAP bug — pin to working version
echo "Fixing comfy_aimdo..."
pip install -q comfy-aimdo==0.3.0 --break-system-packages 2>/dev/null || true

COMFY="/workspace/ComfyUI/models"
HF_TOKEN="${HF_TOKEN:-}"

# Helper: skip if already downloaded
get() {
    local dest="$1"
    local url="$2"
    local auth="$3"
    if [ -f "$dest" ]; then
        echo "  ✓ Already exists: $(basename $dest)"
    else
        echo "  ↓ Downloading: $(basename $dest)..."
        if [ "$auth" = "hf" ]; then
            wget -q --show-progress --header="Authorization: Bearer $HF_TOKEN" -O "$dest" "$url"
        else
            wget -q --show-progress -O "$dest" "$url"
        fi
        echo "  ✓ Done: $(basename $dest)"
    fi
}

mkdir -p \
    $COMFY/diffusion_models \
    $COMFY/text_encoders \
    $COMFY/clip \
    $COMFY/vae \
    $COMFY/ultralytics/bbox \
    $COMFY/sams \
    $COMFY/seedvr2 \
    $COMFY/upscale_models

echo ""
echo "▶ Downloading models..."

# FLUX.2 Klein 9B
get "$COMFY/diffusion_models/flux-2-klein-9b.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b/resolve/main/flux-2-klein-9b.safetensors" hf

# FLUX.2 Klein 9B KV FP8
get "$COMFY/diffusion_models/flux-2-klein-9b-kv-fp8.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-kv-fp8/resolve/main/flux-2-klein-9b-kv-fp8.safetensors" hf

# Z-Image Turbo
get "$COMFY/diffusion_models/z_image_turbo_bf16.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" hf

# Text encoders
get "$COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" hf

get "$COMFY/text_encoders/qwen_3_4b.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" hf

# VAE
get "$COMFY/vae/flux2-vae.safetensors" \
    "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" hf

get "$COMFY/vae/ae.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" hf

# FaceDetailer / SAM
get "$COMFY/ultralytics/bbox/face_yolov8m.pt" \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt"

get "$COMFY/sams/sam_vit_b_01ec64.pth" \
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"

# SeedVR2
get "$COMFY/seedvr2/seedvr2_ema_7b_fp16.safetensors" \
    "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_fp16.safetensors"

get "$COMFY/seedvr2/ema_vae_fp16.safetensors" \
    "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors"

echo ""
echo "✅ All models ready!"

# ── Jupyter config ─────────────────────────────────────────
mkdir -p /root/.jupyter
cat > /root/.jupyter/jupyter_lab_config.py << JCONF
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = ${JUPYTER_PORT:-8888}
c.ServerApp.allow_root = True
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.notebook_dir = '/workspace'
JCONF

# ── Start JupyterLab ───────────────────────────────────────
echo "Starting JupyterLab..."
jupyter lab --config=/root/.jupyter/jupyter_lab_config.py &> /var/log/jupyter.log &

# ── Start ComfyUI ──────────────────────────────────────────
echo "Starting ComfyUI..."
cd /workspace/ComfyUI && python main.py \
    --listen 0.0.0.0 \
    --port ${COMFYUI_PORT:-8188} \
    --enable-cors-header \
    --preview-method auto \
    --disable-mmap
