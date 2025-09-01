// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:rafiqi/constants/colors.dart';
// import 'package:rive/rive.dart';
//
// class InformationPage extends StatefulWidget {
//   @override
//   State<InformationPage> createState() => _InformationPageState();
// }
//
// class _InformationPageState extends State<InformationPage> {
//   Artboard? riveArtboard;
//   late RiveAnimationController controllerIdle;
//   bool isPlaying = true; // Track animation state
//   late ImageProvider informationBackgroundImg =
//       const AssetImage('assets/images/voiceBackground.png');
//   @override
//   void initState() {
//     super.initState();
//     controllerIdle =
//         SimpleAnimation('Animation 1'); // Ensure animation exists in Rive file
//
//     // Load Rive animation file
//     rootBundle.load('assets/soundwave.riv').then((data) {
//       final file = RiveFile.import(data);
//       final artboard = file.mainArtboard;
//
//       // Add animation controller to the artboard
//       artboard.addController(controllerIdle);
//
//       setState(() {
//         riveArtboard = artboard;
//       });
//     });
//   }
//
//   bool _hasPrecached = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_hasPrecached) {
//       _hasPrecached = true;
//       precacheImage(informationBackgroundImg, context);
//     }
//   }
//
//   // Toggle animation play/pause
//   void toggleAnimation() {
//     setState(() {
//       isPlaying = !isPlaying;
//       controllerIdle.isActive = isPlaying;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColor.offWhite,
//       appBar: AppBar(
//         title: const Text(
//           "Voice Help",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: MyColor.myBrown,
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           color: MyColor.offWhite,
//           image: DecorationImage(
//             image: informationBackgroundImg,
//             fit: BoxFit.cover,
//             opacity: 0.3,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Rive Animation Widget
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: 350,
//               child: riveArtboard != null
//                   ? Rive(artboard: riveArtboard!)
//                   : CircularProgressIndicator(),
//             ),
//             // Button to Start/Stop Animation
//             ElevatedButton(
//               onPressed: toggleAnimation,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: MyColor.myBrown,
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: Text(
//                 isPlaying ? "Pause Animation" : "Play Animation",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Chatbot Animation Container
//             Container(
//               decoration: BoxDecoration(
//                 color: MyColor.myBrown,
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               width: MediaQuery.of(context).size.width * 0.7,
//               padding: EdgeInsets.all(14.0),
//               child: SingleChildScrollView(
//                 child: Text(
//                   '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer leo mauris, laoreet vitae mollis non, efficitur eu lectus...''',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
