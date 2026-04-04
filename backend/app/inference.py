from dataclasses import dataclass

import numpy as np
from PIL import Image
import torch

from .config import (
    CLASSIFICATION_THRESHOLD,
    CLASS_NAMES,
    DEVICE,
    IMAGENET_MEAN,
    IMAGENET_STD,
    IMG_SIZE,
    MODEL_WEIGHTS_PATH,
    SEGMENTATION_THRESHOLD,
)
from .image_utils import RoiCrop, build_overlay, image_to_base64
from .model import MultiTaskResNet18UNet


@dataclass(frozen=True)
class InferenceResult:
    predicted_class: str
    confidence: float
    classification_threshold: float
    segmentation_threshold: float
    segmentation_mask_base64: str
    overlay_image_base64: str


class ModelService:
    def __init__(self) -> None:
        self.device = torch.device(DEVICE)
        self.model = MultiTaskResNet18UNet(pretrained=False).to(self.device)
        self.is_ready = False
        self.error_message: str | None = None

    def load(self) -> None:
        try:
            state_dict = torch.load(MODEL_WEIGHTS_PATH, map_location=self.device)
            self.model.load_state_dict(state_dict)
            self.model.eval()
            self.is_ready = True
            self.error_message = None
        except Exception as exc:
            self.is_ready = False
            self.error_message = str(exc)

    def preprocess_roi(self, roi_image: Image.Image) -> torch.Tensor:
        resized = roi_image.resize((IMG_SIZE, IMG_SIZE), Image.BILINEAR)
        image_np = np.array(resized).astype(np.float32) / 255.0
        image_np = (image_np - np.array(IMAGENET_MEAN, dtype=np.float32)) / np.array(
            IMAGENET_STD, dtype=np.float32
        )
        return (
            torch.from_numpy(image_np)
            .permute(2, 0, 1)
            .unsqueeze(0)
            .float()
            .to(self.device)
        )

    def analyze(self, roi_image: Image.Image, roi: RoiCrop) -> InferenceResult:
        if not self.is_ready:
            raise RuntimeError(self.error_message or "Model is not loaded")

        roi_tensor = self.preprocess_roi(roi_image)

        with torch.no_grad():
            seg_logits, cls_logits = self.model(roi_tensor)
            cls_prob = float(torch.sigmoid(cls_logits).item())
            seg_prob = torch.sigmoid(seg_logits)[0, 0].cpu().numpy()

        predicted_index = int(cls_prob > CLASSIFICATION_THRESHOLD)
        predicted_class = CLASS_NAMES.get(predicted_index, str(predicted_index))
        confidence = cls_prob if predicted_index == 1 else 1.0 - cls_prob

        seg_mask = (seg_prob > SEGMENTATION_THRESHOLD).astype(np.uint8) * 255
        mask_image = Image.fromarray(seg_mask).resize((roi.width, roi.height), Image.NEAREST)
        overlay_image = build_overlay(roi_image, mask_image)

        return InferenceResult(
            predicted_class=predicted_class,
            confidence=round(confidence, 4),
            classification_threshold=CLASSIFICATION_THRESHOLD,
            segmentation_threshold=SEGMENTATION_THRESHOLD,
            segmentation_mask_base64=image_to_base64(mask_image),
            overlay_image_base64=image_to_base64(overlay_image),
        )
