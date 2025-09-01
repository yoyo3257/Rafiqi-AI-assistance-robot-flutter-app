import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "http://18.153.59.148:5000";

  Future<Map<String, dynamic>> sendAudioToApi(String audioFilePath) async {
    try {
      final bytes = await File(audioFilePath).readAsBytes();
      final String base64Audio = base64Encode(bytes);

      final url = Uri.parse('$_baseUrl/voice_interface');
      final headers = {"Content-Type": "application/json"};
      final body = json.encode({
        "audio_data": base64Audio,
        "language": "en",
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error sending audio to API: $e");
      rethrow;
    } finally {
      if (File(audioFilePath).existsSync()) {
        File(audioFilePath).delete();
      }
    }
  }
}