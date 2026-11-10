/// Classroom demo URL. Point this at the PHP host (XAMPP).
///
/// Android emulator: http://10.0.2.2/diode_lab/save_result.php
/// iOS simulator / Flutter web on same machine: http://127.0.0.1/diode_lab/save_result.php
/// Physical phone: http://<laptop-lan-ip>/diode_lab/save_result.php
const String saveResultUrl = String.fromEnvironment(
  'SAVE_RESULT_URL',
  defaultValue: 'http://127.0.0.1:8080/save_result.php',
);
