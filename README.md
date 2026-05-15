# RunPod ComfyUI Template

Updated for stable FLUX loading.

Changes made:
- Removed broken mmap fallback patch
- Added --disable-mmap
- Pinned ComfyUI to stable revision 52976f3e
- Switched large downloads to aria2c
- Improved FLUX model download stability
- Added automatic model download on startup

Build:

```bash
cd ~/Desktop/files/runpod-comfyui

git add Dockerfile start.sh download_models.sh README.md

git commit -m "Fix FLUX mmap issues"

git push
```
