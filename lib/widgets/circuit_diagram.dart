import 'package:flutter/material.dart';
import '../theme.dart';

enum CircuitBias { forward, reverse }

class CircuitDiagram extends StatelessWidget {
  const CircuitDiagram({super.key, required this.bias});
  final CircuitBias bias;
  @override
  Widget build(BuildContext context) {
    final forward = bias == CircuitBias.forward;
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(forward ? 'Forward-bias circuit' : 'Reverse-bias circuit',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: LabColors.navy)),
          const SizedBox(height: 10),
          Semantics(
              label:
                  'DC supply, current-limiting resistor and ammeter in series. '
                  'Voltmeter across the diode. Anode connected to ${forward ? 'positive' : 'negative'}.',
              child: AspectRatio(
                  aspectRatio: 360 / 210,
                  child: CustomPaint(painter: _CircuitPainter(forward)))),
          Text(
              forward ? 'Anode to +, cathode to −' : 'Anode to −, cathode to +',
              textAlign: TextAlign.center,
              style: const TextStyle(color: LabColors.muted)),
          const SizedBox(height: 6),
          const Text('A in series · V across the diode · R limits current',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: LabColors.muted)),
        ]));
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.forward);
  final bool forward;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 210);
    final wire = Paint()
      ..color = LabColors.navy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void line(double a, double b, double c, double d) =>
        canvas.drawLine(Offset(a, b), Offset(c, d), wire);
    void text(String s, double x, double y) {
      final p = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: s,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: LabColors.navy)))
        ..layout();
      p.paint(canvas, Offset(x - p.width / 2, y));
    }

    line(25, 105, 25, 65);
    line(25, 65, 78, 65);
    line(125, 65, 146, 65);
    line(174, 65, 247, 65);
    line(275, 65, 335, 65);
    line(335, 65, 335, 190);
    line(335, 190, 25, 190);
    line(25, 190, 25, 123);
    line(forward ? 10 : 17, 105, forward ? 40 : 33, 105);
    line(forward ? 17 : 10, 123, forward ? 33 : 40, 123);
    text(forward ? '+' : '−', 48, 98);
    text(forward ? '−' : '+', 48, 118);
    text('DC', 25, 146);
    final r = Path()..moveTo(78, 65);
    for (var i = 0; i < 6; i++) {
      r.lineTo(78 + (i + 0.5) * 47 / 6, i.isEven ? 57 : 73);
    }
    r.lineTo(125, 65);
    canvas.drawPath(r, wire);
    text('R', 102, 35);
    canvas.drawCircle(const Offset(160, 65), 14, wire);
    text('A', 160, 57);
    text(forward ? 'mA' : 'µA', 160, 86);
    final diode = Path()
      ..moveTo(247, 52)
      ..lineTo(275, 65)
      ..lineTo(247, 78)
      ..close();
    canvas.drawPath(diode, wire);
    line(275, 49, 275, 81);
    text('Anode', 232, 28);
    text('Cathode', 292, 28);
    line(220, 65, 220, 145);
    line(220, 145, 247, 145);
    line(275, 145, 306, 145);
    line(306, 145, 306, 65);
    canvas.drawCircle(const Offset(261, 145), 14, wire);
    text('V', 261, 137);
    text('+', 231, 120);
    text('−', 294, 120);
    for (final x in [220.0, 306.0]) {
      canvas.drawCircle(Offset(x, 65), 3, Paint()..color = LabColors.navy);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) => forward != old.forward;
}
