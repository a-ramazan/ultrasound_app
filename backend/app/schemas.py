from pydantic import BaseModel


class RoiBox(BaseModel):
    x: int
    y: int
    width: int
    height: int


class AnalyzeResponse(BaseModel):
    predicted_class: str
    confidence: float
    classification_threshold: float
    segmentation_threshold: float
    roi: RoiBox
    segmentation_mask_base64: str
    overlay_image_base64: str
