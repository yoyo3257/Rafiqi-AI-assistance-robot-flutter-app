// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rafiqi/widgets/text_and_voice_field.dart';
// import 'package:rafiqi/providers/chat_provider.dart';
// import '../widgets/chat_item2.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   late ImageProvider chatBackgroundImg =
//       const AssetImage('assets/images/chat_background.jpg');
//
//   bool _hasPrecached = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_hasPrecached) {
//       _hasPrecached = true;
//       precacheImage(chatBackgroundImg, context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Chat Help',
//           style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//             borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(200), topLeft: Radius.circular(200)),
//             image: DecorationImage(
//                 image: chatBackgroundImg, fit: BoxFit.cover, opacity: 0.3)),
//         child: Column(
//           children: [
//             Expanded(
//               child: Consumer(builder: (context, ref, child) {
//                 final chats = ref.watch(chatsProvider).reversed.toList();
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: chats.length,
//                   itemBuilder: (context, index) => ChatItem2(
//                       text: chats[index].message, isMe: chats[index].isMe),
//                 );
//               }),
//             ),
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               // child: TextAndVoiceField(),
//             ),
//             const SizedBox(
//               height: 10,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
