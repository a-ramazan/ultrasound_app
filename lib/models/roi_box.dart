import 'dart:ui';

class RoiBox {
  const RoiBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;

  factory RoiBox.fromRect(Rect rect) {
    return RoiBox(
      x: rect.left.round(),
      y: rect.top.round(),
      width: rect.width.round(),
      height: rect.height.round(),
    );
  }
}
