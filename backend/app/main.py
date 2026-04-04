from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from .image_utils import clamp_roi, crop_roi, decode_image_bytes
from .inference import ModelService
from .schemas import AnalyzeResponse, RoiBox


model_service = ModelService()


@asynccontextmanager
async def lifespan(app: FastAPI):
    model_service.load()
    yield


app = FastAPI(
    title="SonoBowel API",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "model_ready": model_service.is_ready,
        "model_error": model_service.error_message,
    }


@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze(
    image: UploadFile = File(...),
    roi_x: int = Form(...),
    roi_y: int = Form(...),
    roi_width: int = Form(...),
    roi_height: int = Form(...),
):
    if not model_service.is_ready:
        raise HTTPException(
            status_code=503,
            detail=model_service.error_message or "Model is not loaded",
        )

    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded image is empty")

    try:
        original_image = decode_image_bytes(image_bytes)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid image file: {exc}") from exc

    clamped_roi = clamp_roi(
        x=roi_x,
        y=roi_y,
        width=roi_width,
        height=roi_height,
        image_width=original_image.width,
        image_height=original_image.height,
    )

    roi_image = crop_roi(original_image, clamped_roi)
    result = model_service.analyze(roi_image, clamped_roi)

    return AnalyzeResponse(
        predicted_class=result.predicted_class,
        confidence=result.confidence,
        classification_threshold=result.classification_threshold,
        segmentation_threshold=result.segmentation_threshold,
        roi=RoiBox(
            x=clamped_roi.x,
            y=clamped_roi.y,
            width=clamped_roi.width,
            height=clamped_roi.height,
        ),
        segmentation_mask_base64=result.segmentation_mask_base64,
        overlay_image_base64=result.overlay_image_base64,
    )
