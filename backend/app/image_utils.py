import base64
import io
from dataclasses import dataclass

import numpy as np
from PIL import Image


@dataclass(frozen=True)
class RoiCrop:
    x: int
    y: int
    width: int
    height: int


def clamp_roi(x: int, y: int, width: int, height: int, image_width: int, image_height: int) -> RoiCrop:
    x = max(0, min(x, image_width - 1))
    y = max(0, min(y, image_height - 1))
    width = max(1, min(width, image_width - x))
    height = max(1, min(height, image_height - y))
    return RoiCrop(x=x, y=y, width=width, height=height)


def decode_image_bytes(image_bytes: bytes) -> Image.Image:
    return Image.open(io.BytesIO(image_bytes)).convert("RGB")


def crop_roi(image: Image.Image, roi: RoiCrop) -> Image.Image:
    return image.crop((roi.x, roi.y, roi.x + roi.width, roi.y + roi.height))


def image_to_base64(image: Image.Image, fmt: str = "PNG") -> str:
    buffer = io.BytesIO()
    image.save(buffer, format=fmt)
    return base64.b64encode(buffer.getvalue()).decode("utf-8")


def build_overlay(roi_rgb: Image.Image, mask_image: Image.Image, alpha: float = 0.45) -> Image.Image:
    roi_np = np.array(roi_rgb).astype(np.uint8)
    mask_np = np.array(mask_image.convert("L")) > 0

    overlay = roi_np.copy()
    if mask_np.any():
        red = np.array([255, 0, 0], dtype=np.float32)
        overlay[mask_np] = (
            overlay[mask_np].astype(np.float32) * (1.0 - alpha) + red * alpha
        ).astype(np.uint8)

    return Image.fromarray(overlay)
