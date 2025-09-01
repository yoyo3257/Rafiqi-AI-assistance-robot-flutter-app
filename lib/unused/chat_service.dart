//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ChatService {
//   static const String _baseUrl = 'http://3.120.134.154:5000'; // Your model API base URL
//
//   Future<Map<String, dynamic>?> sendMessage({
//     required String query,
//     String language = 'en',
//     bool voiceResponse = true,
//   }) async {
//     final url = Uri.parse('$_baseUrl/chat');
//     final headers = {'Content-Type': 'application/json'};
//     final body = json.encode({
//       'query': query,
//       'language': language,
//       'voice_response': voiceResponse,
//     });
//
//     try {
//       final response = await http.post(url, headers: headers, body: body);
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         print('Failed to load response. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error sending message: $e');
//       return null;
//     }
//   }
// }
//
//
// // Example usage in a temporary button click or initState for testing
// // In your main.dart or any widget file for a quick test:
// void main(){
//   void _testChatService() async {
//     final chatService = ChatService();
//     final result = await chatService.sendMessage(query: "Tutankhamun's mask");
//
//     if (result != null) {
//       print('Response: ${result['response']}');
//       print('Suggestions: ${result['suggestions']}');
//     } else {
//       print('Failed to get a response from the chat model.');
//     }
//   }
//   _testChatService();
//
// }

// Call _testChatService() from a button onPressed or initState