import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/diode_model.dart';
import '../theme.dart';

class CombinedCurvePainter extends CustomPainter {
  CombinedCurvePainter(
      {required this.voltage, required this.forward, required this.silicon});
  final double voltage;
  final bool forward, silicon;
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTRB(48, 28, size.width - 16, size.height - 38);
    final zero = Offset(r.left + r.width * 0.55, r.top + r.height * 0.6);
    final m = silicon ? DiodeModel.silicon : DiodeModel.germanium;
    final selected = forward ? m.forwardMilliAmps(voltage) : 0.0;
    final yMax = math.max(20.0, (selected * 1.15 / 20).ceil() * 20.0);
    Offset p(double v, double i, bool f) => Offset(
        f
            ? zero.dx + v * (r.right - zero.dx)
            : zero.dx + v / 10 * (zero.dx - r.left),
        f
            ? zero.dy - i / yMax * (zero.dy - r.top)
            : zero.dy - i / 6 * (r.bottom - zero.dy));
    void label(String s, Offset at, {bool center = false}) {
      final t = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: s,
              style: const TextStyle(fontSize: 10, color: LabColors.muted)))
        ..layout();
      t.paint(canvas, Offset(at.dx - (center ? t.width / 2 : 0), at.dy));
    }

    final grid = Paint()
      ..color = const Color(0xFFE4EAF2)
      ..strokeWidth = 1;
    for (final v in [-10.0, -5.0, 0.0, 0.5, 1.0]) {
      final x = p(v, 0, v >= 0).dx;
      canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), grid);
      label('$v', Offset(x, zero.dy + 6), center: true);
    }
    for (var i = 1; i <= 2; i++) {
      final y = p(0, yMax * i / 2, true).dy;
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), grid);
      label((yMax * i / 2).toStringAsFixed(0), Offset(4, y - 6));
      final yr = p(0, -3.0 * i, false).dy;
      canvas.drawLine(Offset(r.left, yr), Offset(r.right, yr), grid);
      label('−${3 * i}', Offset(4, yr - 6));
    }
    final axis = Paint()
      ..color = LabColors.muted
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(r.left, zero.dy), Offset(r.right, zero.dy), axis);
    canvas.drawLine(Offset(zero.dx, r.top), Offset(zero.dx, r.bottom), axis);
    label('Forward I (mA)', const Offset(0, 0));
    label('Reverse I (µA)', Offset(0, size.height - 12));
    label('V (split scale)', Offset(r.right - 70, size.height - 12));
    canvas.save();
    canvas.clipRect(r.inflate(1));
    void branch(DiodeModel model, Color color, bool f, bool dashed) {
      final path = Path();
      for (var i = 0; i <= 800; i++) {
        final v = i / 800 * (f ? 1 : -10);
        final pt = p(
            v, f ? model.forwardMilliAmps(v) : -model.reverseMicroAmps(-v), f);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;
      if (!dashed) {
        canvas.drawPath(path, paint);
        return;
      }
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 11) {
          canvas.drawPath(
              metric.extractPath(d, math.min(d + 6, metric.length)), paint);
        }
      }
    }

    for (final f in [true, false]) {
      branch(DiodeModel.silicon, LabColors.silicon, f, false);
      branch(DiodeModel.germanium, LabColors.germanium, f, true);
    }
    canvas.restore();
    final pt = p(
        forward ? voltage : -voltage,
        forward ? m.forwardMilliAmps(voltage) : -m.reverseMicroAmps(voltage),
        forward);
    canvas.drawCircle(pt, 5,
        Paint()..color = silicon ? LabColors.silicon : LabColors.germanium);
    canvas.drawCircle(
        pt,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CombinedCurvePainter old) =>
      old.voltage != voltage ||
      old.forward != forward ||
      old.silicon != silicon;
}
