import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class SaveResultResponse {
  const SaveResultResponse({
    required this.ok,
    required this.message,
  });

  final bool ok;
  final String message;
}

class ApiService {
  Future<SaveResultResponse> saveResult({
    required String studentName,
    required int score,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(saveResultUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'student_name': studentName,
              'score': score,
            }),
          )
          .timeout(const Duration(seconds: 12));

      Map<String, dynamic> body = {};
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      }

      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (body['ok'] == true || body['success'] == true);
      final message = (body['message'] as String?) ??
          (ok
              ? 'Result saved.'
              : 'Could not save result (${response.statusCode}).');
      return SaveResultResponse(ok: ok, message: message);
    } catch (error) {
      return SaveResultResponse(
        ok: false,
        message: 'Network error. Check that the PHP API is running. ($error)',
      );
    }
  }
}
