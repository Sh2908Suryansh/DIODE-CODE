import 'dart:math' as math;

/// Representative PN diodes at 25 °C, not a fit to a particular part.
/// I = Is * (exp((V - I*Rs) / (n*Vt)) - 1).
class DiodeModel {
  const DiodeModel(
      {required this.saturationAmps, this.ideality = 2, this.seriesOhms = 2});

  static const thermalVolts = 0.0256926;
  // Calibrated to 1 mA at 0.65 V (Si) and 0.28 V (Ge).
  static final silicon = DiodeModel(
      saturationAmps:
          0.001 / (math.exp((0.65 - 0.001 * 2) / (2 * thermalVolts)) - 1));
  static final germanium = DiodeModel(
      saturationAmps:
          0.001 / (math.exp((0.28 - 0.001 * 2) / (2 * thermalVolts)) - 1));

  final double saturationAmps;
  final double ideality;
  final double seriesOhms;

  double voltageAtCurrent(double amps) =>
      ideality * thermalVolts * math.log(1 + amps / saturationAmps) +
      amps * seriesOhms;

  double forwardMilliAmps(double volts) {
    if (volts <= 0) return 0;
    // Solve the monotonic terminal-voltage equation, including bulk resistance.
    var low = 0.0;
    var high = volts / seriesOhms;
    for (var i = 0; i < 70; i++) {
      final mid = (low + high) / 2;
      if (voltageAtCurrent(mid) > volts) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return (low + high) / 2 * 1000;
  }

  /// Reverse magnitudes only; avalanche/Zener breakdown is outside this model.
  double reverseMicroAmps(double reverseVolts) => reverseVolts <= 0
      ? 0
      : saturationAmps *
          (1 - math.exp(-reverseVolts / (ideality * thermalVolts))) *
          1e6;
}
