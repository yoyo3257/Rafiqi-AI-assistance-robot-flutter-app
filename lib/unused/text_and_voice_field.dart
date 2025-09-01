// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rafiqi/constants/colors.dart';
// import 'package:rafiqi/models/chat_model.dart';
// import 'package:rafiqi/providers/chat_provider.dart';
// import 'package:rafiqi/services/speech_to_text_service.dart';
// import 'package:rafiqi/widgets/toggel_Button.dart';
//
// import '../services/ai_handler.dart';
//
// enum InputMode {
//   text,
//   voice,
// }
//
// class TextAndVoiceField extends ConsumerStatefulWidget {
//   const TextAndVoiceField({super.key});
//
//   @override
//   ConsumerState<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
// }
//
// class _TextAndVoiceFieldState extends ConsumerState<TextAndVoiceField> {
//   InputMode _inputMode = InputMode.voice;
//   final _messageController = TextEditingController();
//   final AIHandler _openAI = AIHandler();
//   final STT voiceHandler = STT();
//   var _isReplying = false;
//   var _isListening = false;
//   @override
//   void initState() {
//     voiceHandler.initSpeech();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _messageController,
//             onChanged: (value) {
//               value.isNotEmpty
//                   ? setInputMode(InputMode.text)
//                   : setInputMode(InputMode.voice);
//             },
//             cursorColor: Theme.of(context).colorScheme.onPrimary,
//             decoration: InputDecoration(
//                 fillColor: Colors.white,
//                 filled: true,
//                 hintStyle: TextStyle(color: MyColor.offWhite),
//                 hintText: 'Ask me anything',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: MyColor.offWhite,
//                     ),
//                     borderRadius: BorderRadius.circular(70))),
//           ),
//         ),
//         const SizedBox(
//           width: 6,
//         ),
//         ToggleButton(
//           isListening: _isListening,
//           isReplying: _isReplying,
//           inputMode: _inputMode,
//           sendTextMessage: () {
//             final message = _messageController.text;
//             print('message send');
//             print(message);
//             sendTextMessage(message);
//             _messageController.clear();
//           },
//           sendVoiceMessage: sendVoiceMessage,
//         )
//       ],
//     );
//   }
//
//   void setInputMode(InputMode inputMode) {
//     setState(() {
//       _inputMode = inputMode;
//     });
//   }
//
//   void sendVoiceMessage() async {
//     if (!voiceHandler.isEnabled) {
//       print('Not supported');
//       return;
//     }
//     if (voiceHandler.speechToText.isListening) {
//       await voiceHandler.stopListening();
//       setListeningState(false);
//     } else {
//       setListeningState(true);
//       final result = await voiceHandler.startListening();
//       setListeningState(false);
//       sendTextMessage(result);
//     }
//   }
//
//   void sendTextMessage(String message) async {
//     setReplyingState(true);
//     addToChatList(message, true, DateTime.now().toString());
//     addToChatList('Typing...', false, 'typing');
//     setInputMode(InputMode.voice);
//     final aiResponse = await _openAI.getResponse(message);
//     removeTyping();
//     addToChatList(aiResponse, false, DateTime.now().toString());
//     setReplyingState(false);
//   }
//
//   void setReplyingState(bool isReplying) {
//     setState(() {
//       _isReplying = isReplying;
//     });
//   }
//
//   void setListeningState(bool isListening) {
//     setState(() {
//       _isListening = isListening;
//     });
//   }
//
//   void removeTyping() {
//     final chats = ref.read(chatsProvider.notifier);
//     chats.removeTyping();
//   }
//
//   void addToChatList(String message, bool isMe, String id) {
//     final chats = ref.read(chatsProvider.notifier);
//     chats.add(ChatModel(
//       id: id,
//       message: message,
//       isMe: isMe,
//     ));
//   }
// }
