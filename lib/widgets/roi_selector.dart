import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum _DragMode {
  move,
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class RoiSelector extends StatefulWidget {
  const RoiSelector({
    super.key,
    required this.imageBytes,
    required this.imageSize,
    required this.onChanged,
  });

  final Uint8List imageBytes;
  final Size imageSize;
  final ValueChanged<Rect?> onChanged;

  @override
  State<RoiSelector> createState() => _RoiSelectorState();
}

class _RoiSelectorState extends State<RoiSelector> {
  static const double _edgeHit = 28;
  static const double _minSize = 56;

  Rect? _selection;
  Rect? _lastImageRect;
  _DragMode? _dragMode;
  Offset? _lastPoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _imageRectForContain(
          source: widget.imageSize,
          destination: containerSize,
        );

        _syncSelectionWithImageRect(imageRect);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) =>
              _onPanStart(details.localPosition, imageRect),
          onPanUpdate: (details) =>
              _onPanUpdate(details.localPosition, imageRect),
          onPanEnd: (_) {
            _dragMode = null;
            _lastPoint = null;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFFD9E8ED),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                ),
              ),
              CustomPaint(
                painter: _RoiOverlayPainter(
                  imageRect: imageRect,
                  selection: _selection,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncSelectionWithImageRect(Rect imageRect) {
    if (_selection == null || _lastImageRect != imageRect) {
      final width = imageRect.width * 0.52;
      final height = imageRect.height * 0.42;
      final left = imageRect.left + (imageRect.width - width) / 2;
      final top = imageRect.top + (imageRect.height - height) / 2;
      _selection = Rect.fromLTWH(left, top, width, height);
      _lastImageRect = imageRect;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selection != null) {
          widget.onChanged(_toImageRect(_selection!, imageRect));
        }
      });
    }
  }

  void _onPanStart(Offset point, Rect imageRect) {
    final selection = _selection;
    if (selection == null) {
      return;
    }

    _dragMode = _hitTest(point, selection);
    _lastPoint = point;

    if (_dragMode == null && selection.contains(point)) {
      _dragMode = _DragMode.move;
    }

    if (_dragMode == null) {
      final centerRect = Rect.fromCenter(
        center: _clampToRect(point, imageRect),
        width: imageRect.width * 0.28,
        height: imageRect.height * 0.24,
      );
      _selection = _normalizeRect(centerRect, imageRect, _DragMode.move);
      _dragMode = _DragMode.move;
      _lastPoint = point;
      setState(() {});
      widget.onChanged(_toImageRect(_selection!, imageRect));
    }
  }

  void _onPanUpdate(Offset point, Rect imageRect) {
    final selection = _selection;
    final dragMode = _dragMode;
    final lastPoint = _lastPoint;
    if (selection == null || dragMode == null || lastPoint == null) {
      return;
    }

    final delta = point - lastPoint;
    Rect next = selection;

    switch (dragMode) {
      case _DragMode.move:
        next = next.shift(delta);
      case _DragMode.left:
        next = Rect.fromLTRB(
          next.left + delta.dx,
          next.top,
          next.right,
          next.bottom,
        );
      case _DragMode.right:
        next = Rect.fromLTRB(
          next.left,
          next.top,
          next.right + delta.dx,
          next.bottom,
        );
      case _DragMode.top:
        next = Rect.fromLTRB(
          next.left,
          next.top + delta.dy,
          next.right,
          next.bottom,
        );
      case _DragMode.bottom:
        next = Rect.fromLTRB(
          next.left,
          next.top,
          next.right,
          next.bottom + delta.dy,
        );
      case _DragMode.topLeft:
        next = Rect.fromLTRB(
          next.left + delta.dx,
          next.top + delta.dy,
          next.right,
          next.bottom,
        );
      case _DragMode.topRight:
        next = Rect.fromLTRB(
          next.left,
          next.top + delta.dy,
          next.right + delta.dx,
          next.bottom,
        );
      case _DragMode.bottomLeft:
        next = Rect.fromLTRB(
          next.left + delta.dx,
          next.top,
          next.right,
          next.bottom + delta.dy,
        );
      case _DragMode.bottomRight:
        next = Rect.fromLTRB(
          next.left,
          next.top,
          next.right + delta.dx,
          next.bottom + delta.dy,
        );
    }

    next = _normalizeRect(next, imageRect, dragMode);

    setState(() {
      _selection = next;
      _lastPoint = point;
    });
    widget.onChanged(_toImageRect(next, imageRect));
  }

  _DragMode? _hitTest(Offset point, Rect rect) {
    final nearLeft = (point.dx - rect.left).abs() <= _edgeHit;
    final nearRight = (point.dx - rect.right).abs() <= _edgeHit;
    final nearTop = (point.dy - rect.top).abs() <= _edgeHit;
    final nearBottom = (point.dy - rect.bottom).abs() <= _edgeHit;

    final withinVertical =
        point.dy >= rect.top - _edgeHit && point.dy <= rect.bottom + _edgeHit;
    final withinHorizontal =
        point.dx >= rect.left - _edgeHit && point.dx <= rect.right + _edgeHit;

    if (nearLeft && nearTop) {
      return _DragMode.topLeft;
    }
    if (nearRight && nearTop) {
      return _DragMode.topRight;
    }
    if (nearLeft && nearBottom) {
      return _DragMode.bottomLeft;
    }
    if (nearRight && nearBottom) {
      return _DragMode.bottomRight;
    }
    if (nearLeft && withinVertical) {
      return _DragMode.left;
    }
    if (nearRight && withinVertical) {
      return _DragMode.right;
    }
    if (nearTop && withinHorizontal) {
      return _DragMode.top;
    }
    if (nearBottom && withinHorizontal) {
      return _DragMode.bottom;
    }
    return null;
  }

  Rect _normalizeRect(Rect rect, Rect bounds, _DragMode mode) {
    double left = rect.left;
    double top = rect.top;
    double right = rect.right;
    double bottom = rect.bottom;

    if (mode == _DragMode.move) {
      final width = right - left;
      final height = bottom - top;
      left = left.clamp(bounds.left, bounds.right - width);
      top = top.clamp(bounds.top, bounds.bottom - height);
      right = left + width;
      bottom = top + height;
      return Rect.fromLTRB(left, top, right, bottom);
    }

    if (right - left < _minSize) {
      if (mode == _DragMode.left ||
          mode == _DragMode.topLeft ||
          mode == _DragMode.bottomLeft) {
        left = right - _minSize;
      } else {
        right = left + _minSize;
      }
    }

    if (bottom - top < _minSize) {
      if (mode == _DragMode.top ||
          mode == _DragMode.topLeft ||
          mode == _DragMode.topRight) {
        top = bottom - _minSize;
      } else {
        bottom = top + _minSize;
      }
    }

    left = left.clamp(bounds.left, bounds.right - _minSize);
    top = top.clamp(bounds.top, bounds.bottom - _minSize);
    right = right.clamp(bounds.left + _minSize, bounds.right);
    bottom = bottom.clamp(bounds.top + _minSize, bounds.bottom);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _imageRectForContain({required Size source, required Size destination}) {
    final fitted = applyBoxFit(BoxFit.contain, source, destination);
    final renderSize = fitted.destination;
    final dx = (destination.width - renderSize.width) / 2;
    final dy = (destination.height - renderSize.height) / 2;
    return Rect.fromLTWH(dx, dy, renderSize.width, renderSize.height);
  }

  Offset _clampToRect(Offset point, Rect rect) {
    return Offset(
      point.dx.clamp(rect.left, rect.right),
      point.dy.clamp(rect.top, rect.bottom),
    );
  }

  Rect _toImageRect(Rect rect, Rect imageRect) {
    final left =
        ((rect.left - imageRect.left) / imageRect.width) *
        widget.imageSize.width;
    final top =
        ((rect.top - imageRect.top) / imageRect.height) *
        widget.imageSize.height;
    final width = (rect.width / imageRect.width) * widget.imageSize.width;
    final height = (rect.height / imageRect.height) * widget.imageSize.height;
    return Rect.fromLTWH(left, top, width, height);
  }
}

class _RoiOverlayPainter extends CustomPainter {
  const _RoiOverlayPainter({required this.imageRect, required this.selection});

  final Rect imageRect;
  final Rect? selection;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.deepNavy.withValues(alpha: 0.22);
    final clearPath = Path()..addRect(Offset.zero & size);
    clearPath.addRect(selection ?? imageRect);
    clearPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(clearPath, fillPaint);

    final imageBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(imageRect, const Radius.circular(24)),
      imageBorder,
    );

    if (selection != null) {
      final border = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(selection!, const Radius.circular(18)),
        border,
      );

      final edgePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final rect = selection!;
      const grip = 18.0;

      canvas.drawLine(
        Offset(rect.center.dx - grip, rect.top),
        Offset(rect.center.dx + grip, rect.top),
        edgePaint,
      );
      canvas.drawLine(
        Offset(rect.center.dx - grip, rect.bottom),
        Offset(rect.center.dx + grip, rect.bottom),
        edgePaint,
      );
      canvas.drawLine(
        Offset(rect.left, rect.center.dy - grip),
        Offset(rect.left, rect.center.dy + grip),
        edgePaint,
      );
      canvas.drawLine(
        Offset(rect.right, rect.center.dy - grip),
        Offset(rect.right, rect.center.dy + grip),
        edgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoiOverlayPainter oldDelegate) {
    return oldDelegate.selection != selection ||
        oldDelegate.imageRect != imageRect;
  }
}
