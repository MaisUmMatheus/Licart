import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gerador pseudo-aleatório baseado no algoritmo de sementes (LCG)
class _SeededRng {
  int _state;
  _SeededRng(int seed) : _state = seed & 0xFFFFFFFF;

  double next() {
    _state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF;
    return _state / 4294967296.0;
  }
}

/// Pintor customizado que renderiza respingos e pinceladas de nanquim procedurais
class InkSplatterPainter extends CustomPainter {
  final int seed;
  final Color inkColor;
  final double sizeRatio;
  final bool drawStroke;
  final bool drawDrip;
  final double? customCenterY;

  const InkSplatterPainter({
    required this.seed,
    this.inkColor = const Color(0xFF0D0D0D),
    this.sizeRatio = 0.22,
    this.drawStroke = true,
    this.drawDrip = true,
    this.customCenterY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rng = _SeededRng(seed);
    final paint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.5;
    final cy = size.height * (customCenterY ?? 0.5);
    final r = math.min(size.width, size.height) * sizeRatio;

    // 1. Pinceladas secas de fundo (Brush strokes)
    if (drawStroke) {
      final y0 = cy - r * 1.1;
      final x0 = cx - r * 1.6;
      final len = r * 3.2;

      for (int i = 0; i < 36; i++) {
        final off = (rng.next() - 0.5) * r * 0.35;
        final wdt = 1.0 + rng.next() * r * 0.06;
        strokePaint.strokeWidth = wdt;
        strokePaint.color = inkColor.withValues(alpha: 0.85);

        final path = Path();
        path.moveTo(x0 + rng.next() * r * 0.2, y0 + off);
        path.cubicTo(
          x0 + len * 0.3,
          y0 + off - r * 0.25,
          x0 + len * 0.65,
          y0 + off + r * 0.2,
          x0 + len * (0.8 + rng.next() * 0.2),
          y0 + off - r * 0.05,
        );
        canvas.drawPath(path, strokePaint);
      }
    }

    // 2. Mancha central (Main blob)
    final blobPath = Path();
    const int n = 28;
    for (int i = 0; i <= n; i++) {
      final a = (i / n) * math.pi * 2;
      final rr = r * (0.7 + rng.next() * 0.45);
      final x = cx + math.cos(a) * rr;
      final y = cy + math.sin(a) * rr;
      if (i == 0) {
        blobPath.moveTo(x, y);
      } else {
        blobPath.lineTo(x, y);
      }
    }
    blobPath.close();
    paint.color = inkColor;
    canvas.drawPath(blobPath, paint);

    // 3. Braços e filamentos de nanquim (Tendrils + Drops)
    final arms = 10 + (rng.next() * 8).floor();
    for (int k = 0; k < arms; k++) {
      final a = rng.next() * math.pi * 2;
      final l = r * (1.1 + rng.next() * 1.4);
      const steps = 10;
      for (int i = 0; i < steps; i++) {
        final t = i / steps.toDouble();
        final dropX = cx + math.cos(a) * (r * 0.6 + l * t);
        final dropY = cy + math.sin(a) * (r * 0.6 + l * t);
        final dropRadius = r * 0.16 * (1.0 - t) + 1.0;
        canvas.drawCircle(Offset(dropX, dropY), dropRadius, paint);
      }

      // Gota final do filamento
      final endX = cx + math.cos(a) * (r * 0.6 + l * 1.08);
      final endY = cy + math.sin(a) * (r * 0.6 + l * 1.08);
      final endRadius = r * (0.04 + rng.next() * 0.07);
      canvas.drawCircle(Offset(endX, endY), endRadius, paint);
    }

    // 4. Micro-respingos dispersos (Splatter dots)
    for (int k = 0; k < 70; k++) {
      final a = rng.next() * math.pi * 2;
      final d = r * (1.0 + math.pow(rng.next(), 0.6) * 2.6);
      final s = r * (0.01 + math.pow(rng.next(), 3.0) * 0.12);
      final speckX = cx + math.cos(a) * d;
      final speckY = cy + math.sin(a) * d;
      canvas.drawCircle(Offset(speckX, speckY), s, paint);
    }

    // 5. Escorrido vertical (Drip)
    if (drawDrip) {
      final dx = cx + (rng.next() - 0.5) * r * 0.6;
      final dripHeight = r * (1.4 + rng.next() * 0.8);
      final dripWidth = r * 0.08;

      canvas.drawRect(
        Rect.fromLTWH(dx - dripWidth / 2, cy, dripWidth, dripHeight),
        paint,
      );
      canvas.drawCircle(Offset(dx, cy + dripHeight + r * 0.1), dripWidth, paint);
    }
  }

  @override
  bool shouldRepaint(covariant InkSplatterPainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.inkColor != inkColor ||
        oldDelegate.sizeRatio != sizeRatio ||
        oldDelegate.drawStroke != drawStroke ||
        oldDelegate.drawDrip != drawDrip ||
        oldDelegate.customCenterY != customCenterY;
  }
}
