import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CirclesPainter extends CustomPainter {
  CirclesPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final circles = [
      (Offset(w * 0.0, h * 0.55), w * 0.55, colors[0]),
      (Offset(w * 0.95, h * 0.05), w * 0.45, colors[1]),
      (Offset(w * 0.75, h * 1.05), w * 0.50, colors[2]),
    ];
    for (final (center, radius, color) in circles) {
      canvas.drawCircle(center, radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(CirclesPainter old) => !listEquals(old.colors, colors);
}
