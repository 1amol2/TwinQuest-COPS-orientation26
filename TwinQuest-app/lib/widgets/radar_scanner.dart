import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class RadarScanner extends StatefulWidget {
  final Color accentColor;
  final double size;

  const RadarScanner({
    super.key,
    this.accentColor = AppColors.blue,
    this.size = 200,
  });

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(
            angle: _controller.value * 2 * pi,
            color: widget.accentColor,
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  final Color color;

  _RadarPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric radar rings
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, (radius / 3) * i, ringPaint);
    }

    // Draw rotating radar sweep line
    final sweepPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final sweepEnd = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawLine(center, sweepEnd, sweepPaint);

    // Draw center pulse dot
    final centerDot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerDot);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
  }
}
