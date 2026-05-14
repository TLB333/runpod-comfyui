#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  download_models.sh — runs automatically on pod start
#  Downloads every model needed by all 4 workflows
# ─────────────────────────────────────────────────────────────

set -e

COMFY="/workspace/ComfyUI/models"

# Helper: skip if already downloaded
get() {
    local dest="$1"
    local url="$2"
    if [ -f "$dest" ]; then
        echo "  ✓ Already exists: $(basename $dest)"
    else
        echo "  ↓ Downloading: $(basename $dest)..."
        wget -q --show-progress -O "$dest" "$url"
        echo "  ✓ Done: $(basename $dest)"
    fi
}

# Ensure all model dirs exist
mkdir -p \
    $COMFY/diffusion_models \
    $COMFY/unet \
    $COMFY/text_encoders \
    $COMFY/clip \
    $COMFY/vae \
    $COMFY/ultralytics/bbox \
    $COMFY/sams \
    $COMFY/seedvr2 \
    $COMFY/upscale_models

echo ""
echo "════════════════════════════════════════════════"
echo "  Downloading models for all 4 workflows"
echo "════════════════════════════════════════════════"

# ── FLUX.2 Klein 9B (used by: Carousel, BG Change, Img2Img) ──
echo ""
echo "▶ FLUX.2 Klein 9B diffusion model..."
get "$COMFY/diffusion_models/flux-2-klein-9b.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b/resolve/main/flux-2-klein-9b.safetensors"

# ── FLUX.2 Klein 9B KV FP8 (used by: BG Change) ──────────────
echo ""
echo "▶ FLUX.2 Klein 9B KV FP8..."
get "$COMFY/diffusion_models/flux-2-klein-9b-kv-fp8.safetensors" \
    "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-kv-fp8/resolve/main/flux-2-klein-9b-kv-fp8.safetensors"

# ── Z-Image Turbo (used by: Img2Img, TEXTGen) ─────────────────
echo ""
echo "▶ Z-Image Turbo BF16..."
get "$COMFY/diffusion_models/z_image_turbo_bf16.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors"

# ── Text Encoders ─────────────────────────────────────────────
echo ""
echo "▶ Text encoders..."

# Qwen 3 8B FP8 — used by Carousel, BG Change, Img2Img
get "$COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
    "https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors"

# Qwen 3 4B — used by Img2Img (Z-Image), TEXTGen
get "$COMFY/text_encoders/qwen_3_4b.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

# Also copy to /clip folder as some nodes look there
cp -n $COMFY/text_encoders/qwen_3_8b_fp8mixed.safetensors $COMFY/clip/ 2>/dev/null || true
cp -n $COMFY/text_encoders/qwen_3_4b.safetensors $COMFY/clip/ 2>/dev/null || true

# ── VAE ───────────────────────────────────────────────────────
echo ""
echo "▶ VAE models..."

# flux2-vae — used by Carousel, BG Change, Img2Img
get "$COMFY/vae/flux2-vae.safetensors" \
    "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors"

# ae.safetensors — used by Img2Img (Z-Image), TEXTGen
get "$COMFY/vae/ae.safetensors" \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# ── Impact Pack models ────────────────────────────────────────
echo ""
echo "▶ Impact Pack / FaceDetailer models..."

get "$COMFY/ultralytics/bbox/face_yolov8m.pt" \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt"

get "$COMFY/sams/sam_vit_b_01ec64.pth" \
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"

# ── SeedVR2 models (used by: TEXTGen) ─────────────────────────
echo ""
echo "▶ SeedVR2 upscaler models..."

get "$COMFY/seedvr2/seedvr2_ema_7b_fp16.safetensors" \
    "https://huggingface.co/ByteDance/SeedVR2/resolve/main/seedvr2_ema_7b_fp16.safetensors"

get "$COMFY/seedvr2/ema_vae_fp16.safetensors" \
    "https://huggingface.co/ByteDance/SeedVR2/resolve/main/ema_vae_fp16.safetensors"

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ All models downloaded!"
echo "  LoRAs are already baked into the image."
echo "════════════════════════════════════════════════"
echo ""
