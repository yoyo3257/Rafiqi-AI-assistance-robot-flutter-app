// import 'package:flutter/material.dart';
// import 'package:rafiqi/constants/colors.dart';
//
// class ChatItem2 extends StatelessWidget {
//   final String text;
//   final bool isMe;
//   const ChatItem2({super.key, required this.text, required this.isMe});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment:
//         isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isMe) ProfileContainer(isMe: isMe),
//           if (!isMe) const SizedBox(width: 5),
//           Container(
//             padding: const EdgeInsets.all(15),
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.65,
//             ),
//             decoration: BoxDecoration(
//               color: isMe
//                   ?  Colors.white.withValues(alpha: 0.85)
//                   :MyColor.myBrown,
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(15),
//                 topRight: const Radius.circular(15),
//                 bottomLeft: Radius.circular(isMe ? 15 : 0),
//                 bottomRight: Radius.circular(isMe ? 0 : 15),
//               ),
//             ),
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: isMe ? MyColor.brownOne :Colors.white ,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//           if (isMe) const SizedBox(width: 5),
//           if (isMe) ProfileContainer(isMe: isMe),
//         ],
//       ),
//     );
//   }
// }
//
// class ProfileContainer extends StatelessWidget {
//   const ProfileContainer({super.key, required this.isMe});
//   final bool isMe;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Image.asset(
//           isMe
//               ? 'assets/traveler.png'
//               : 'assets/rafiqi_icon.png',
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
