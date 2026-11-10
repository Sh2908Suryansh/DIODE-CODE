import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_diode_lab/models/diode_model.dart';

void main() {
  test('both polarities have zero current at zero voltage', () {
    for (final m in [DiodeModel.silicon, DiodeModel.germanium]) {
      expect(m.forwardMilliAmps(0), 0);
      expect(m.reverseMicroAmps(0), 0);
    }
  });
  test('forward solver satisfies Shockley equation with internal resistance',
      () {
    for (final m in [DiodeModel.silicon, DiodeModel.germanium]) {
      for (final v in [0.02, 0.1, 0.3, 0.65, 0.8, 1.0]) {
        final amps = m.forwardMilliAmps(v) / 1000;
        final junctionCurrent = m.saturationAmps *
            (math.exp((v - amps * m.seriesOhms) /
                    (m.ideality * DiodeModel.thermalVolts)) -
                1);
        expect(amps, closeTo(junctionCurrent, 1e-12));
      }
    }
  });
  test('current rises continuously through 20 mA without a plateau', () {
    for (final m in [DiodeModel.silicon, DiodeModel.germanium]) {
      final crossing = m.voltageAtCurrent(0.02);
      expect(m.forwardMilliAmps(crossing - 0.01), lessThan(20));
      expect(m.forwardMilliAmps(crossing), closeTo(20, 1e-8));
      expect(m.forwardMilliAmps(crossing + 0.01), greaterThan(20));
      var previous = 0.0;
      for (var i = 1; i <= 100; i++) {
        final next = m.forwardMilliAmps(i / 100);
        expect(next, greaterThan(previous));
        previous = next;
      }
    }
  });
  test('reference points, material comparison and reverse saturation agree',
      () {
    expect(DiodeModel.silicon.forwardMilliAmps(0.65), closeTo(1, 1e-9));
    expect(DiodeModel.germanium.forwardMilliAmps(0.28), closeTo(1, 1e-9));
    expect(DiodeModel.germanium.forwardMilliAmps(0.4),
        greaterThan(DiodeModel.silicon.forwardMilliAmps(0.4)));
    for (final m in [DiodeModel.silicon, DiodeModel.germanium]) {
      expect(m.reverseMicroAmps(0.01), lessThan(m.reverseMicroAmps(1)));
      expect(m.reverseMicroAmps(1), closeTo(m.saturationAmps * 1e6, 1e-6));
      expect(m.reverseMicroAmps(10), closeTo(m.reverseMicroAmps(1), 1e-6));
    }
    expect(DiodeModel.germanium.reverseMicroAmps(5),
        greaterThan(DiodeModel.silicon.reverseMicroAmps(5)));
  });
}
