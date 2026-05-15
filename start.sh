#!/bin/bash
set -e

echo "════════════════════════════════════════════════"
echo "  RunPod | ComfyUI + JupyterLab"
echo "════════════════════════════════════════════════"

HF_TOKEN="${HF_TOKEN:-}"
COMFY="/workspace/ComfyUI"
MODELS="$COMFY/models"

# Install ComfyUI if not present on volume
if [ ! -f "$COMFY/main.py" ]; then
    echo "First run - installing ComfyUI to network volume..."
    git clone https://github.com/comfyanonymous/ComfyUI.git $COMFY
    pip install --no-cache-dir -q -r $COMFY/requirements.txt

    echo "Installing custom nodes..."
    cd $COMFY/custom_nodes

    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && pip install -q -r ComfyUI-Manager/requirements.txt
    git clone https://github.com/rgthree/rgthree-comfy.git && pip install -q -r rgthree-comfy/requirements.txt 2>/dev/null || true
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && pip install -q -r ComfyUI-KJNodes/requirements.txt 2>/dev/null || true
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && pip install -q -r ComfyUI-Easy-Use/requirements.txt 2>/dev/null || true
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git && pip install -q -r ComfyUI_Comfyroll_CustomNodes/requirements.txt 2>/dev/null || true
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && pip install -q piexif opencv-python-headless pycocotools scikit-image watchdog 2>/dev/null || true
    git clone https://github.com/city96/ComfyUI-GGUF.git && pip install -q -r ComfyUI-GGUF/requirements.txt 2>/dev/null || true
    git clone https://github.com/ainvfx/ComfyUI-SeedVR2_VideoUpscaler.git && pip install -q -r ComfyUI-SeedVR2_VideoUpscaler/requirements.txt 2>/dev/null || true
    git clone https://github.com/spacepxl/ComfyUI-Image-Filters.git && pip install -q -r ComfyUI-Image-Filters/requirements.txt 2>/dev/null || true
    git clone https://github.com/cubiq/ComfyUI_essentials.git && pip install -q -r ComfyUI_essentials/requirements.txt 2>/dev/null || true
    git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && pip install -q -r was-node-suite-comfyui/requirements.txt 2>/dev/null || true
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git && cd ComfyUI-Impact-Subpack && python install.py 2>/dev/null || true && pip install -q -r requirements.txt 2>/dev/null || true && cd ..
    git clone https://github.com/ClownsharkBatwing/RES4LYF.git && pip install -q -r RES4LYF/requirements.txt 2>/dev/null || true
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git && pip install -q -r comfyui-vrgamedevgirl/requirements.txt 2>/dev/null || true

    mkdir -p $COMFY/user/default/workflows
    cp /data/workflows/* $COMFY/user/default/workflows/ 2>/dev/null || true
    mkdir -p $MODELS/loras
    cp /data/loras/* $MODELS/loras/ 2>/dev/null || true
    mkdir -p $MODELS/ultralytics
    cp -r /data/ultralytics/* $MODELS/ultralytics/ 2>/dev/null || true

    echo "ComfyUI installed!"
else
    echo "ComfyUI already installed - skipping"
fi

get() {
    local dest="$1" url="$2" auth="$3"
    if [ -f "$dest" ]; then echo "  ✓ $(basename $dest)"; return; fi
    echo "  ↓ Downloading $(basename $dest)..."
    if [ "$auth" = "hf" ]; then
        wget -q --show-progress --header="Authorization: Bearer $HF_TOKEN" -O "$dest" "$url"
    else
        wget -q --show-progress -O "$dest" "$url"
    fi
}

mkdir -p $MODELS/diffusion_models $MODELS/text_encoders $MODELS/vae $MODELS/sams $MODELS/seedvr2 $MODELS/ultralytics/bbox

echo "Downloading models..."
get "$MODELS/diffusion_models/flux-2-klein-9b.safetensors" "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b/resolve/main/flux-2-klein-9b.safetensors" hf
get "$MODELS/diffusion_models/flux-2-klein-9b-kv-fp8.safetensors" "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-kv-fp8/resolve/main/flux-2-klein-9b-kv-fp8.safetensors" hf
get "$MODELS/diffusion_models/z_image_turbo_bf16.safetensors" "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" hf
get "$MODELS/text_encoders/qwen_3_8b_fp8mixed.safetensors" "https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" hf
get "$MODELS/text_encoders/qwen_3_4b.safetensors" "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" hf
get "$MODELS/vae/flux2-vae.safetensors" "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" hf
get "$MODELS/vae/ae.safetensors" "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" hf
get "$MODELS/ultralytics/bbox/face_yolov8m.pt" "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt"
get "$MODELS/sams/sam_vit_b_01ec64.pth" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"
get "$MODELS/seedvr2/seedvr2_ema_7b_fp16.safetensors" "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_fp16.safetensors"
get "$MODELS/seedvr2/ema_vae_fp16.safetensors" "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors"

echo "All models ready!"

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

echo "Starting JupyterLab..."
jupyter lab --config=/root/.jupyter/jupyter_lab_config.py &> /var/log/jupyter.log &

echo "Starting ComfyUI..."
cd $COMFY && python main.py \
    --listen 0.0.0.0 \
    --port ${COMFYUI_PORT:-8188} \
    --enable-cors-header \
    --preview-method auto \
    --disable-mmap
