import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;

  WaveformPainter({required this.amplitudes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final middleY = size.height / 2;
    final widthBetweenBars = size.width / amplitudes.length.clamp(1, 50);

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * widthBetweenBars;
      // Scale amplitude to the height of the container
      final barHeight = amplitudes[i] * size.height;

      canvas.drawLine(
        Offset(x, middleY - (barHeight / 2)),
        Offset(x, middleY + (barHeight / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    // Repaint whenever new audio amplitude arrays stream in
    return oldDelegate.amplitudes != amplitudes;
  }
}