import 'package:flutter/services.dart';

const _channel = MethodChannel('diode_lab/data');
Future<String?> loadData() async {
  try {
    return await _channel.invokeMethod<String>('load');
  } on MissingPluginException {
    return null;
  }
}

Future<void> storeData(String json) async {
  try {
    await _channel.invokeMethod<void>('save', json);
  } on MissingPluginException {/* Desktop/test session remains in memory. */}
}

Future<bool> exportCsv(String csv) async =>
    await _channel.invokeMethod<bool>('exportCsv', csv) ?? false;
