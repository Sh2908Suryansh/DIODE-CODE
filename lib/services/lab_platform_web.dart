// Browser storage and download APIs; this app also targets Android.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String?> loadData() async => html.window.localStorage['diode_lab_v2'];
Future<void> storeData(String json) async {
  html.window.localStorage['diode_lab_v2'] = json;
}

Future<bool> exportCsv(String csv) async {
  final url = html.Url.createObjectUrlFromBlob(
      html.Blob(['\uFEFF', csv], 'text/csv;charset=utf-8'));
  final anchor = html.AnchorElement(href: url)
    ..download = 'diode-lab-readings.csv';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Let the browser consume the URL before releasing it.
  Future<void>.delayed(
      const Duration(seconds: 10), () => html.Url.revokeObjectUrl(url));
  return true;
}
