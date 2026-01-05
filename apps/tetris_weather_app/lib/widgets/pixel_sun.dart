import 'dart:math';

import 'package:flutter/material.dart';

class PixelSun extends StatefulWidget {
  const PixelSun({
    super.key,
    this.size = 104,
    this.spread = 1.45,
    this.intensity = 1.0,
    this.duration = const Duration(milliseconds: 2400),
    this.coreColor = const Color(0xFFFFB84C),
    this.rayColor = const Color(0xFFFFE8A3),
    this.glowColor = const Color(0xFFFFF3C1),
  });

  final double size;
  final double spread;
  final double intensity;
  final Duration duration;
  final Color coreColor;
  final Color rayColor;
  final Color glowColor;

  @override
  State<PixelSun> createState() => _PixelSunState();
}

class _PixelSunState extends State<PixelSun>
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final cell = widget.size / 12;
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _BlockSunPainter(
              progress: _controller.value,
              cell: cell,
              coreColor: widget.coreColor,
              rayColor: widget.rayColor,
              glowColor: widget.glowColor,
              spread: widget.spread,
              intensity: widget.intensity,
            ),
          );
        },
      ),
    );
  }
}

class _BlockSunPainter extends CustomPainter {
  const _BlockSunPainter({
    required this.progress,
    required this.cell,
    required this.coreColor,
    required this.rayColor,
    required this.glowColor,
    required this.spread,
    required this.intensity,
  });

  final double progress;
  final double cell;
  final Color coreColor;
  final Color rayColor;
  final Color glowColor;
  final double spread;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

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
          ..color = Colors.white.withOpacity(0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final glowRadius = (cell * 5.2 * intensity) +
        sin(progress * pi * 2) * cell * 0.6 * intensity;
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withOpacity(0.46),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
    );

    final pulse = 1 + sin(progress * pi * 2) * 0.16 * intensity;
    final wave = (2.6 + sin(progress * pi * 2) * 0.9) * intensity;
    final outerWave = wave * spread;
    final fade = 0.38 + (1 - progress) * 0.32;

    final coreOffsets = [
      Offset.zero,
      Offset(-cell, 0),
      Offset(cell, 0),
      Offset(0, -cell),
      Offset(0, cell),
      Offset(-cell, -cell),
      Offset(cell, -cell),
      Offset(-cell, cell),
      Offset(cell, cell),
    ];
    for (final offset in coreOffsets) {
      drawPixel(center + offset, coreColor.withOpacity(0.94), scale: pulse);
    }

    final rayOffsets = [
      Offset(0, -2 * cell),
      Offset(0, 2 * cell),
      Offset(2 * cell, 0),
      Offset(-2 * cell, 0),
      Offset(cell, -cell * 2),
      Offset(-cell, -cell * 2),
      Offset(cell, cell * 2),
      Offset(-cell, cell * 2),
    ];
    for (final offset in rayOffsets) {
      drawPixel(center + offset, rayColor.withOpacity(0.9));
    }

    final animated = [
      Offset(0, -wave * cell),
      Offset(0, wave * cell),
      Offset(wave * cell, 0),
      Offset(-wave * cell, 0),
      Offset(wave * 0.8 * cell, -wave * 0.8 * cell),
      Offset(-wave * 0.8 * cell, -wave * 0.8 * cell),
      Offset(wave * 0.8 * cell, wave * 0.8 * cell),
      Offset(-wave * 0.8 * cell, wave * 0.8 * cell),
    ];
    for (final offset in animated) {
      drawPixel(
        center + offset,
        rayColor.withOpacity(0.55 * fade),
        scale: 0.86,
      );
    }

    final burst = [
      Offset(0, -outerWave * cell),
      Offset(0, outerWave * cell),
      Offset(outerWave * cell, 0),
      Offset(-outerWave * cell, 0),
      Offset(outerWave * 0.86 * cell, -outerWave * 0.86 * cell),
      Offset(-outerWave * 0.86 * cell, -outerWave * 0.86 * cell),
      Offset(outerWave * 0.86 * cell, outerWave * 0.86 * cell),
      Offset(-outerWave * 0.86 * cell, outerWave * 0.86 * cell),
    ];
    for (final offset in burst) {
      drawPixel(
        center + offset,
        rayColor.withOpacity(0.32 * fade),
        scale: 0.82,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlockSunPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        cell != oldDelegate.cell ||
        spread != oldDelegate.spread ||
        intensity != oldDelegate.intensity ||
        coreColor != oldDelegate.coreColor ||
        rayColor != oldDelegate.rayColor ||
        glowColor != oldDelegate.glowColor;
  }
}
