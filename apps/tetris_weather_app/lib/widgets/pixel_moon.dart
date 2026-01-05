import 'dart:math';

import 'package:flutter/material.dart';

class PixelMoon extends StatefulWidget {
  const PixelMoon({
    super.key,
    this.size = 104,
    this.spread = 1.35,
    this.intensity = 1.0,
    this.duration = const Duration(milliseconds: 2600),
    this.coreColor = const Color(0xFFC9DFFF),
    this.rayColor = const Color(0xFF9BB2FF),
    this.glowColor = const Color(0xFFB6C8FF),
    this.shadowColor = const Color(0xFF0A1021),
  });

  final double size;
  final double spread;
  final double intensity;
  final Duration duration;
  final Color coreColor;
  final Color rayColor;
  final Color glowColor;
  final Color shadowColor;

  @override
  State<PixelMoon> createState() => _PixelMoonState();
}

class _PixelMoonState extends State<PixelMoon>
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
            painter: _PixelMoonPainter(
              progress: _controller.value,
              cell: cell,
              coreColor: widget.coreColor,
              rayColor: widget.rayColor,
              glowColor: widget.glowColor,
              shadowColor: widget.shadowColor,
              spread: widget.spread,
              intensity: widget.intensity,
            ),
          );
        },
      ),
    );
  }
}

class _PixelMoonPainter extends CustomPainter {
  const _PixelMoonPainter({
    required this.progress,
    required this.cell,
    required this.coreColor,
    required this.rayColor,
    required this.glowColor,
    required this.shadowColor,
    required this.spread,
    required this.intensity,
  });

  final double progress;
  final double cell;
  final Color coreColor;
  final Color rayColor;
  final Color glowColor;
  final Color shadowColor;
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
          ..color = Colors.white.withOpacity(0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final glowCenter = center + Offset(cell * 2.4, 0); // 只在亮侧扩散
    final glowRadius = (cell * 3.6 * intensity) +
        sin(progress * pi * 2) * cell * 0.4 * intensity;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withOpacity(0.32),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );

    // Base disc
    for (int x = -3; x <= 3; x++) {
      for (int y = -3; y <= 3; y++) {
        final dx = x.toDouble();
        final dy = y.toDouble();
        final dist = sqrt(dx * dx + dy * dy);
        if (dist <= 3.2) {
          drawPixel(
            center + Offset(dx * cell, dy * cell),
            coreColor.withOpacity(0.94),
          );
        }
      }
    }

    // Shadow cut-out to form crescent
    for (int x = -3; x <= 3; x++) {
      for (int y = -3; y <= 3; y++) {
        final dx = x.toDouble();
        final dy = y.toDouble();
        final dist = sqrt(pow(dx + 1.3, 2) + pow(dy, 2));
        if (dist <= 2.6) {
          drawPixel(
            center + Offset(dx * cell, dy * cell),
            shadowColor.withOpacity(0.7),
          );
        }
      }
    }

    // Small crater details
    final craters = <Offset>[
      Offset(cell * 0.4, -cell * 1.6),
      Offset(cell * 1.2, cell * 0.6),
      Offset(-cell * 0.2, cell * 1.2),
    ];
    for (final offset in craters) {
      drawPixel(
        center + offset,
        coreColor.withOpacity(0.5),
        scale: 0.7,
      );
    }

    final wave = (2.2 + sin(progress * pi * 2) * 0.8) * intensity;
    final outerWave = wave * spread;
    final fade = 0.35 + (1 - progress) * 0.3;

    final orbit = [
      Offset(wave * cell, 0),
      Offset(wave * 0.9 * cell, -wave * 0.4 * cell),
      Offset(wave * 0.9 * cell, wave * 0.4 * cell),
      Offset(wave * 0.65 * cell, -wave * 0.9 * cell),
      Offset(wave * 0.65 * cell, wave * 0.9 * cell),
    ];
    for (final offset in orbit) {
      drawPixel(
        center + offset,
        rayColor.withOpacity(0.54 * fade),
        scale: 0.76,
      );
    }

    final stars = [
      Offset(outerWave * cell, 0),
      Offset(outerWave * 0.9 * cell, outerWave * 0.4 * cell),
      Offset(outerWave * 0.9 * cell, -outerWave * 0.4 * cell),
      Offset(outerWave * 0.78 * cell, outerWave * 0.9 * cell),
      Offset(outerWave * 0.78 * cell, -outerWave * 0.9 * cell),
    ];
    for (final offset in stars) {
      drawPixel(
        center + offset,
        rayColor.withOpacity(0.3 * fade),
        scale: 0.64,
      );
    }

    final beams = [
      Offset(wave * 0.82 * cell, -outerWave * 1.15 * cell),
      Offset(wave * 0.82 * cell, -outerWave * 1.32 * cell),
      Offset(wave * 0.82 * cell, outerWave * 1.15 * cell),
      Offset(wave * 0.82 * cell, outerWave * 1.32 * cell),
    ];
    for (final offset in beams) {
      drawPixel(
        center + offset,
        rayColor.withOpacity(0.42 * fade),
        scale: 0.78,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelMoonPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        cell != oldDelegate.cell ||
        spread != oldDelegate.spread ||
        intensity != oldDelegate.intensity ||
        coreColor != oldDelegate.coreColor ||
        rayColor != oldDelegate.rayColor ||
        glowColor != oldDelegate.glowColor ||
        shadowColor != oldDelegate.shadowColor;
  }
}
