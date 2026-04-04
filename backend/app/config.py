from pathlib import Path
import json


BASE_DIR = Path(__file__).resolve().parent.parent

# Default paths can be overridden later via environment variables if needed.
MODEL_WEIGHTS_PATH = Path(r"C:\Users\abdra\Desktop\0304\best_semiauto_multitask.pth")
METRICS_PATH = Path(r"C:\Users\abdra\Desktop\0304\best_metrics.json")
SEG_SWEEP_PATH = Path(r"C:\Users\abdra\Desktop\0304\seg_threshold_sweep.json")

IMG_SIZE = 256
DEVICE = "cpu"

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)

CLASS_NAMES = {
    0: "normal",
    1: "pathology",
}


def _load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


_metrics = _load_json(METRICS_PATH)
_seg_metrics = _load_json(SEG_SWEEP_PATH)

CLASSIFICATION_THRESHOLD = float(_metrics.get("cls_threshold", 0.50))
SEGMENTATION_THRESHOLD = float(_seg_metrics.get("best_threshold", 0.50))
