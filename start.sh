#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  start.sh — RunPod entrypoint
#  1. Runs your model download script (if present)
#  2. Starts JupyterLab
#  3. Starts ComfyUI
# ─────────────────────────────────────────────────────────────
set -e

echo "════════════════════════════════════════════════"
echo "  RunPod | ComfyUI + JupyterLab"
echo "  Workflows: Carousel, BG Change, Img2Img, Text"
echo "════════════════════════════════════════════════"

# ── Run model download script if it exists ────────────────────
# Drop your download script at /workspace/download_models.sh
# It will run automatically every time the pod starts.
# Models saved to /workspace/ComfyUI/models/* persist across restarts
# if you mounted a network volume at /workspace.

if [ -f "/workspace/download_models.sh" ]; then
    echo "[setup] Found download_models.sh — running it now..."
    bash /workspace/download_models.sh
    echo "[setup] Downloads complete."
else
    echo "[setup] No /workspace/download_models.sh found — skipping."
    echo "        To add one: upload it via JupyterLab and restart the pod."
fi

# ── JupyterLab config ─────────────────────────────────────────
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

# ── Start JupyterLab (background) ────────────────────────────
echo "[1/2] Starting JupyterLab on port ${JUPYTER_PORT:-8888}..."
jupyter lab --config=/root/.jupyter/jupyter_lab_config.py \
    &> /var/log/jupyter.log &
echo "      PID: $!"

# ── Start ComfyUI (foreground — keeps container alive) ────────
echo "[2/2] Starting ComfyUI on port ${COMFYUI_PORT:-8188}..."
cd /workspace/ComfyUI && python main.py \
    --listen 0.0.0.0 \
    --port ${COMFYUI_PORT:-8188} \
    --enable-cors-header \
    --preview-method auto
