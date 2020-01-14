import 'package:flutter/material.dart';
import 'dart:ui' as ui;

///🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️
/// Image Helpers
/// Extending ui.Image to make it easier to draw to the screen
final kTargetRect = Rect.fromCenter(center: Offset.zero, width: 1, height: 1);

extension ImageHelpers on ui.Image {
  // Draws a Square Image rotated at offset around it's axis
  void drawRotatedSquare(
      {Canvas canvas,
      double size,
      Offset offset,
      double rotation,
      Paint paint,
      bool flip = false}) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (flip) {
      canvas.scale(-1, 1);
    }

    canvas.rotate(flip ? -rotation : rotation);
    canvas.scale(size);
    canvas.drawImageRect(this, bounds(), kTargetRect, paint);
    canvas.restore();
  }

  Rect bounds() =>
      Rect.fromLTRB(0, 0, this.width.toDouble(), this.height.toDouble());
}
