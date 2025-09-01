// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//
// String my_api = "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";
//
// class AIHandler {
//   final _openAI = OpenAI.instance.build(
//     token: my_api,
//     baseOption: HttpSetup(
//       receiveTimeout: const Duration(seconds: 60),
//       connectTimeout: const Duration(seconds: 60),
//     ),
//   );
//
//   Future<String> getResponse(String message) async {
//     try {
//       // Create the request object
//       final request = ChatCompleteText(
//         messages: [
//           {"role": "user", "content": message}
//         ],
//         maxToken: 200,
//         model: Gpt4oMiniChatModel(),
//       );
// //old:  Gpt4oMiniChatModel()
//       // Call the OpenAI API
//       final response = await _openAI.onChatCompletion(request: request);
//
//       // Check for a valid response and choices
//       if (response != null && response.choices.isNotEmpty) {
//         final content = response.choices[0].message?.content.trim() ?? 'No response content';
//         return content;
//       }
//
//       // Return a fallback message if response is invalid
//       return 'Something went wrong';
//     } catch (e) {
//       // Log or print the error for debugging purposes
//       print('Error in getResponse: $e');
//       return 'Bad response';
//     }
//   }
//
// }
//
//
