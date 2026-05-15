#!/bin/bash
set -e

echo "════════════════════════════════════════════════"
echo "  RunPod | ComfyUI + JupyterLab"
echo "════════════════════════════════════════════════"

COMFY="/workspace/ComfyUI/models"
HF_TOKEN="${HF_TOKEN:-}"

mkdir -p \
    $COMFY/diffusion_models \
    $COMFY/text_encoders \
    $COMFY/clip \
    $COMFY/vae \
    $COMFY/ultralytics/bbox \
    $COMFY/sams \
    $COMFY/seedvr2

echo ""
echo "▶ Running model download script..."
bash /download_models.sh

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

echo "Starting JupyterLab..."
jupyter lab --config=/root/.jupyter/jupyter_lab_config.py &> /var/log/jupyter.log &

echo "Starting ComfyUI..."
cd /workspace/ComfyUI && python main.py \
    --listen 0.0.0.0 \
    --port ${COMFYUI_PORT:-8188} \
    --enable-cors-header "*" \
    --preview-method auto \
    --disable-mmap
