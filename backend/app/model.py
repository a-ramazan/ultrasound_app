import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import models


class ConvRelu(nn.Module):
    def __init__(self, in_channels: int, out_channels: int):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1, bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, kernel_size=3, padding=1, bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.block(x)


class UpBlock(nn.Module):
    def __init__(self, in_channels: int, skip_channels: int, out_channels: int):
        super().__init__()
        self.conv = ConvRelu(in_channels + skip_channels, out_channels)

    def forward(self, x: torch.Tensor, skip: torch.Tensor) -> torch.Tensor:
        x = F.interpolate(x, size=skip.shape[-2:], mode="bilinear", align_corners=False)
        x = torch.cat([x, skip], dim=1)
        return self.conv(x)


class MultiTaskResNet18UNet(nn.Module):
    def __init__(self, pretrained: bool = False):
        super().__init__()

        if pretrained:
            try:
                backbone = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
            except Exception:
                backbone = models.resnet18(pretrained=True)
        else:
            try:
                backbone = models.resnet18(weights=None)
            except Exception:
                backbone = models.resnet18(pretrained=False)

        self.stem_conv = backbone.conv1
        self.stem_bn = backbone.bn1
        self.stem_relu = backbone.relu
        self.stem_pool = backbone.maxpool

        self.layer1 = backbone.layer1
        self.layer2 = backbone.layer2
        self.layer3 = backbone.layer3
        self.layer4 = backbone.layer4

        self.up3 = UpBlock(512, 256, 256)
        self.up2 = UpBlock(256, 128, 128)
        self.up1 = UpBlock(128, 64, 64)
        self.up0 = UpBlock(64, 64, 64)

        self.final_conv = ConvRelu(64, 64)
        self.seg_head = nn.Conv2d(64, 1, kernel_size=1)

        self.cls_head = nn.Sequential(
            nn.AdaptiveAvgPool2d(1),
            nn.Flatten(),
            nn.Linear(512, 128),
            nn.ReLU(inplace=True),
            nn.Dropout(0.2),
            nn.Linear(128, 1),
        )

    def forward(self, x: torch.Tensor) -> tuple[torch.Tensor, torch.Tensor]:
        s0 = self.stem_relu(self.stem_bn(self.stem_conv(x)))
        x = self.stem_pool(s0)
        s1 = self.layer1(x)
        s2 = self.layer2(s1)
        s3 = self.layer3(s2)
        b = self.layer4(s3)

        cls_logits = self.cls_head(b)

        d3 = self.up3(b, s3)
        d2 = self.up2(d3, s2)
        d1 = self.up1(d2, s1)
        d0 = self.up0(d1, s0)
        d0 = F.interpolate(d0, scale_factor=2, mode="bilinear", align_corners=False)
        d0 = self.final_conv(d0)

        seg_logits = self.seg_head(d0)
        return seg_logits, cls_logits
