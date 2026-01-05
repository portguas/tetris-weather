import 'dart:math';

import 'package:flutter/material.dart';

class PixelCloud extends StatefulWidget {
  const PixelCloud({
    super.key,
    this.size = 110,
    this.drift = 1.0,
    this.intensity = 1.0,
    this.duration = const Duration(milliseconds: 3000),
    this.puffColor = const Color(0xFFDCE7FF),
    this.highlightColor = const Color(0xFFF4F7FF),
    this.shadowColor = const Color(0xFF8FA4C5),
  });

  final double size;
  final double drift;
  final double intensity;
  final Duration duration;
  final Color puffColor;
  final Color highlightColor;
  final Color shadowColor;

  @override
  State<PixelCloud> createState() => _PixelCloudState();
}

class _PixelCloudState extends State<PixelCloud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
      builder: (context, _) {
        final cell = widget.size / 16;
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.75),
          painter: _PixelCloudPainter(
            progress: _controller.value,
            cell: cell,
            drift: widget.drift,
            intensity: widget.intensity,
            puffColor: widget.puffColor,
            highlightColor: widget.highlightColor,
            shadowColor: widget.shadowColor,
          ),
        );
      },
    );
  }
}

class _PixelCloudPainter extends CustomPainter {
  const _PixelCloudPainter({
    required this.progress,
    required this.cell,
    required this.drift,
    required this.intensity,
    required this.puffColor,
    required this.highlightColor,
    required this.shadowColor,
  });

  final double progress;
  final double cell;
  final double drift;
  final double intensity;
  final Color puffColor;
  final Color highlightColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.55;
    final driftOffset = sin(progress * pi * 2) * cell * 0.7 * drift * intensity;
    final bob = sin(progress * pi * 2 * 0.6) * cell * 0.3 * intensity;
    final center = Offset(size.width * 0.48 + driftOffset, baseY + bob);

    void drawPixel(Offset offset, Color color, {double scale = 1}) {
      final rect = Rect.fromCenter(
        center: offset,
        width: cell * scale,
        height: cell * scale,
      );
      canvas.drawRect(rect, Paint()..color = color);
      canvas.drawRect(
        rect.deflate(cell * 0.18 * scale),
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final puffOffsets = <Offset>[
      Offset(-3 * cell, 0),
      Offset(-2 * cell, 0),
      Offset(-1 * cell, 0),
      Offset(0, 0),
      Offset(cell, 0),
      Offset(2 * cell, 0),
      Offset(3 * cell, 0),
      Offset(-2 * cell, cell),
      Offset(-1 * cell, cell),
      Offset(0, cell),
      Offset(cell, cell),
      Offset(2 * cell, cell),
      Offset(-1 * cell, 2 * cell),
      Offset(0, 2 * cell),
      Offset(0, 3 * cell / 2),
      Offset(-3 * cell, -cell),
      Offset(-2 * cell, -cell),
      Offset(-1 * cell, -cell),
      Offset(0, -cell),
      Offset(cell, -cell),
      Offset(2 * cell, -cell),
      Offset(-1 * cell, -2 * cell),
      Offset(0, -2 * cell),
      Offset(cell, -2 * cell),
    ];
    for (final offset in puffOffsets) {
      drawPixel(center + offset, puffColor.withOpacity(0.92));
    }

    // Top highlights
    final highlightOffsets = <Offset>[
      Offset(-cell, -cell * 1.2),
      Offset(0, -cell * 1.2),
      Offset(cell, -cell * 1.2),
      Offset(2 * cell, -cell),
    ];
    for (final offset in highlightOffsets) {
      drawPixel(center + offset, highlightColor.withOpacity(0.9));
    }

    // Bottom shadow
    final shadowOffsets = <Offset>[
      Offset(-2 * cell, cell * 1.6),
      Offset(-cell, cell * 1.6),
      Offset(0, cell * 1.6),
      Offset(cell, cell * 1.6),
      Offset(2 * cell, cell * 1.6),
      Offset(-cell, cell * 2),
      Offset(0, cell * 2),
      Offset(cell, cell * 2),
    ];
    for (final offset in shadowOffsets) {
      drawPixel(center + offset, shadowColor.withOpacity(0.65));
    }

    // Side soft edges
    final sideSoft = [
      Offset(3.2 * cell, -cell * 0.4),
      Offset(-3.2 * cell, -cell * 0.4),
      Offset(3.2 * cell, cell * 0.6),
      Offset(-3.2 * cell, cell * 0.6),
    ];
    for (final p in sideSoft) {
      drawPixel(p + center, puffColor.withOpacity(0.55), scale: 0.68);
    }
  }

  @override
  bool shouldRepaint(covariant _PixelCloudPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        cell != oldDelegate.cell ||
        drift != oldDelegate.drift ||
        intensity != oldDelegate.intensity ||
        puffColor != oldDelegate.puffColor ||
        highlightColor != oldDelegate.highlightColor ||
        shadowColor != oldDelegate.shadowColor;
  }
}
