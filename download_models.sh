#!/bin/bash
set -e

COMFY="/workspace/ComfyUI/models"
HF_TOKEN="${HF_TOKEN:-}"

aria_download() {
    local dest="$1"
    local url="$2"

    if [ -f "$dest" ]; then
        echo "✓ Already exists: $(basename $dest)"
    else
        echo "↓ Downloading: $(basename $dest)"

        aria2c \
            -x 16 -s 16 -k 1M \
            --file-allocation=none \
            --header="Authorization: Bearer $HF_TOKEN" \
            -d "$(dirname "$dest")" \
            -o "$(basename "$dest")" \
            "$url"
    fi
}

mkdir -p \
    $COMFY/diffusion_models \
    $COMFY/text_encoders \
    $COMFY/clip \
    $COMFY/vae \
    $COMFY/ultralytics/bbox \
    $COMFY/sams \
    $COMFY/seedvr2

# Remove potentially corrupted FLUX encoder
rm -f $COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors.tmp

echo "════════════════════════════════════════════════"
echo "Downloading models"
echo "════════════════════════════════════════════════"

# FLUX
aria_download "$COMFY/diffusion_models/flux-2-klein-9b.safetensors" \
"https://huggingface.co/black-forest-labs/FLUX.2-klein-9b/resolve/main/flux-2-klein-9b.safetensors"

aria_download "$COMFY/diffusion_models/flux-2-klein-9b-kv-fp8.safetensors" \
"https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-kv-fp8/resolve/main/flux-2-klein-9b-kv-fp8.safetensors"

# Z-Image
aria_download "$COMFY/diffusion_models/z_image_turbo_bf16.safetensors" \
"https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors"

# Text Encoders
aria_download "$COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
"https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors"

aria_download "$COMFY/text_encoders/qwen_3_4b.safetensors" \
"https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

# Copy encoders to clip folder
cp -n $COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors $COMFY/clip/ 2>/dev/null || true
cp -n $COMFY/text_encoders/qwen_3_4b.safetensors $COMFY/clip/ 2>/dev/null || true

# VAE
aria_download "$COMFY/vae/flux2-vae.safetensors" \
"https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors"

aria_download "$COMFY/vae/ae.safetensors" \
"https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# Impact Pack
aria_download "$COMFY/ultralytics/bbox/face_yolov8m.pt" \
"https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt"

aria_download "$COMFY/sams/sam_vit_b_01ec64.pth" \
"https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"

# SeedVR2
aria_download "$COMFY/seedvr2/seedvr2_ema_7b_fp16.safetensors" \
"https://huggingface.co/ByteDance/SeedVR2/resolve/main/seedvr2_ema_7b_fp16.safetensors"

aria_download "$COMFY/seedvr2/ema_vae_fp16.safetensors" \
"https://huggingface.co/ByteDance/SeedVR2/resolve/main/ema_vae_fp16.safetensors"

echo ""
echo "✅ All models downloaded successfully"
