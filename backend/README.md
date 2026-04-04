# SonoBowel Backend

FastAPI backend for ROI-based bowel ultrasound analysis.

## What it does

- Accepts the original ultrasound image
- Accepts ROI coordinates selected by the user
- Crops the ROI on the server
- Runs the multitask model
- Returns:
  - predicted class
  - confidence
  - segmentation mask
  - overlay preview

## Expected model files

This backend is prepared for the PyTorch weights file:

- `C:\Users\abdra\Desktop\0304\best_semiauto_multitask.pth`

The model architecture was reconstructed from:

- `C:\Users\abdra\Desktop\0304\multitask.py`

## API

### `GET /health`

Returns service status and model readiness.

### `POST /analyze`

Multipart form-data:

- `image`: original image file
- `roi_x`: integer
- `roi_y`: integer
- `roi_width`: integer
- `roi_height`: integer

Response JSON:

- `predicted_class`
- `confidence`
- `segmentation_threshold`
- `classification_threshold`
- `roi`
- `segmentation_mask_base64`
- `overlay_image_base64`

## Local run

1. Create a Python virtual environment
2. Install dependencies from `requirements.txt`
3. Start the server:

```bash
uvicorn app.main:app --reload --port 8000
```

## Notes

- The current class mapping assumes binary classification:
  - `0 -> normal`
  - `1 -> pathology`
- Thresholds are set from code defaults for now because no exported metrics file was found next to the model.
- If you later export the best thresholds from training, update `app/config.py`.
