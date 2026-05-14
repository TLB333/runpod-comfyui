# RunPod Template — ComfyUI + JupyterLab
### Workflows included: CarouselPosechanger · Flux Background Change · Img2Img Upscaler FLUX · TEXTGen

---

## What's in this image

| Component | Details |
|---|---|
| Base | RunPod PyTorch 2.1 · CUDA 12.1 · Ubuntu 22.04 |
| ComfyUI | Latest from GitHub |
| ComfyUI Manager | Install/update nodes from the UI |
| JupyterLab | Port 8888 — file manager + terminal |
| Your 4 workflows | Pre-loaded in ComfyUI on first launch |

### Custom nodes pre-installed
| Node pack | Used by |
|---|---|
| rgthree-comfy | Any Switch, Image Comparer, Fast Groups Bypasser, Label, Mute/Bypass |
| ComfyUI-KJNodes | PathchSageAttentionKJ, LazySwitchKJ, FluxKVCache |
| ComfyUI-Easy-Use | All `easy *` nodes |
| ComfyUI_Comfyroll | CR Prompt List |
| ComfyUI-Impact-Pack | FaceDetailer, SAMLoader, UltralyticsDetectorProvider |
| ComfyUI-clownsampler | ClownsharKSampler_Beta, SharkChainsampler_Beta, BetaSamplingScheduler |
| ComfyUI-ReferenceLatent | ReferenceLatent |
| ComfyUI-GGUF | EmptyFlux2LatentImage, Flux2Scheduler |
| ComfyUI-SeedVR2 | SeedVR2 upscaler nodes |
| ComfyUI-Color-Transfer | ColorTransfer |
| ComfyUI-Image-Filters | FastFilmGrain |
| ComfyUI_essentials | ImageResize+, ImageScaleToMaxDimension, ImageSharpen, GetImageSize |
| was-node-suite | Fallback WAS nodes |

---

## Folder structure on your Mac

```
runpod-comfyui/
├── Dockerfile
├── start.sh
├── download_models.sh    ← edit this with YOUR model URLs
├── README.md
└── workflows/
    ├── CarouselPosechanger.json
    ├── V3_-_Flux9backround_change.json
    ├── ZiT_img2img___Upscaler_FLUX.json
    └── ZIT_TEXTGen.json
```

> **Important:** Create the `workflows/` folder and copy your 4 JSON files into it before building.

---

## Step 1 — Set up your folder

```bash
mkdir -p runpod-comfyui/workflows
cd runpod-comfyui

# Copy your workflow files in
cp /path/to/CarouselPosechanger.json workflows/
cp /path/to/V3_-_Flux9backround_change.json workflows/
cp /path/to/ZiT_img2img___Upscaler_FLUX.json workflows/
cp /path/to/ZIT_TEXTGen.json workflows/
```

---

## Step 2 — Edit your download script

Open `download_models.sh` and uncomment + fill in the URLs for your models (checkpoints, LoRAs, VAE, etc). These download automatically each time the pod starts.

If your models are on **CivitAI**, you need your API token:
```bash
wget --header="Authorization: Bearer YOUR_CIVITAI_TOKEN" -O model.safetensors "https://..."
```

---

## Step 3 — Build the image (on your Mac)

```bash
# Apple Silicon (M1/M2/M3) — required flag for NVIDIA compatibility
docker buildx build --platform linux/amd64 -t yourdockerhubname/comfyui-runpod:latest .

# Intel Mac — standard build
docker build -t yourdockerhubname/comfyui-runpod:latest .
```

> First build takes 20–40 min. Subsequent builds are fast (Docker caches layers).

---

## Step 4 — Push to Docker Hub

```bash
docker login
docker push yourdockerhubname/comfyui-runpod:latest
```

Your image URL: `yourdockerhubname/comfyui-runpod:latest`

---

## Step 5 — Create the RunPod Template

1. Go to [runpod.io](https://runpod.io) → **Templates** → **New Template**

| Field | Value |
|---|---|
| Template Name | ComfyUI Workflows |
| Container Image | `yourdockerhubname/comfyui-runpod:latest` |
| Container Disk | 20 GB |
| Volume Disk | 50–100 GB |
| Volume Mount Path | `/workspace` |
| Expose HTTP Ports | `8188, 8888` |
| Docker Command | *(leave blank)* |

2. Save Template

---

## Step 6 — Deploy & connect

1. **Pods → Deploy** → pick a GPU → select your template → Deploy
2. Once running, click **Connect**
3. You'll see two HTTP links:
   - **Port 8188** → ComfyUI (your workflows are in the queue menu)
   - **Port 8888** → JupyterLab (terminal, file manager)

---

## Adding / updating your download script after deploy

1. Open JupyterLab (port 8888)
2. Upload your `download_models.sh` to `/workspace/`
3. Restart the pod — it runs automatically on next start

---

## Ports reference

| Port | Service |
|---|---|
| 8188 | ComfyUI |
| 8888 | JupyterLab |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Missing node" red error in workflow | Open ComfyUI Manager → Install Missing Nodes |
| Models not found | Check paths in `download_models.sh` match the model folder locations above |
| Out of VRAM | Add `--lowvram` to the ComfyUI launch command in `start.sh` |
| Build fails on Mac | Make sure Docker Desktop is running; use `--platform linux/amd64` on Apple Silicon |
| Workflows not showing | Check they're in `workflows/` folder before building |
