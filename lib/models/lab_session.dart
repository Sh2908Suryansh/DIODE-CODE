import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/lab_platform.dart' as platform;

class Observation {
  const Observation(
      {required this.silicon,
      required this.forward,
      required this.volts,
      required this.amps});
  final bool silicon, forward;
  final double volts, amps;
  Map<String, dynamic> toJson() =>
      {'silicon': silicon, 'forward': forward, 'volts': volts, 'amps': amps};
  factory Observation.fromJson(Map<String, dynamic> data) => Observation(
      silicon: data['silicon'] as bool,
      forward: data['forward'] as bool,
      volts: (data['volts'] as num).toDouble(),
      amps: (data['amps'] as num).toDouble());
}

class LabSession {
  static final instance = LabSession();
  double voltage = 0.65, reverseVoltage = 5;
  bool silicon = true, forward = true, combined = false;
  final observations = <Observation>[];
  Map<String, dynamic> quiz = {};
  final storageError = ValueNotifier<bool>(false);
  Future<void> _pending = Future.value();

  Map<String, dynamic> toJson() => {
        'voltage': voltage,
        'reverseVoltage': reverseVoltage,
        'silicon': silicon,
        'forward': forward,
        'combined': combined,
        'observations': observations.map((o) => o.toJson()).toList(),
        'quiz': quiz
      };
  void restore(Map<String, dynamic> data) {
    voltage = ((data['voltage'] as num?)?.toDouble() ?? 0.65).clamp(0, 1);
    reverseVoltage =
        ((data['reverseVoltage'] as num?)?.toDouble() ?? 5).clamp(0, 10);
    silicon = data['silicon'] as bool? ?? true;
    forward = data['forward'] as bool? ?? true;
    combined = data['combined'] as bool? ?? false;
    observations
      ..clear()
      ..addAll((data['observations'] as List? ?? [])
          .map((o) => Observation.fromJson(Map<String, dynamic>.from(o))));
    quiz = Map<String, dynamic>.from(data['quiz'] as Map? ?? {});
  }

  Future<void> load() async {
    try {
      final json = await platform.loadData();
      if (json != null) restore(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      storageError.value = true;
    }
  }

  void save() {
    final json = jsonEncode(toJson());
    _pending = _pending.then((_) async {
      try {
        await platform.storeData(json);
        storageError.value = false;
      } catch (_) {
        storageError.value = true;
      }
    });
  }

  String csv() => [
        'Reading,Material,Bias,Diode voltage (V signed),Diode current (A signed),Temperature (C),Source',
        for (var i = 0; i < observations.length; i++)
          '${i + 1},${observations[i].silicon ? 'Silicon' : 'Germanium'},'
              '${observations[i].forward ? 'Forward' : 'Reverse'},'
              '${observations[i].volts},${observations[i].amps},25,Illustrative Shockley model'
      ].join('\r\n');
  void reset() {
    voltage = 0.65;
    reverseVoltage = 5;
    silicon = true;
    forward = true;
    combined = false;
    observations.clear();
    quiz = {};
    storageError.value = false;
  }
}
