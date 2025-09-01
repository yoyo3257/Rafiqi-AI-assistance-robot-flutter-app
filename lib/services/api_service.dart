import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiService {
  static const String _baseUrl = 'http://18.153.59.148:5000';

  Future<Map<String, dynamic>> sendMessage({
    required String query,
    required String language,
  }) async {
    final url = Uri.parse('$_baseUrl/chat');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query,
          'language': language,
          'voice_response': false, // Explicitly set to false for text-only
        }),
      );

      if (kDebugMode) {
        print('Sending to Flask: ${json.encode({
    'query': query,
    'language': language,
    'voice_response': false,
  })}');
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load response: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }
}