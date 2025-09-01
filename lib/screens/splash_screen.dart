import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'face_model_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/new_ui/welcome_background.jpg'),
        context,
      );
      precacheImage(
        const AssetImage('assets/images/new_ui/voiceBackground.png'),
        context,
      );
      precacheImage(
          const AssetImage('assets/images/new_ui/chat_background.jpg'), context);
    });

  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.gif(
      gifPath: 'assets/RAfiqi.gif',
      gifWidth: 700,
      gifHeight: 700,
      backgroundColor: const Color(0xfff6f6f6),
      duration: const Duration(seconds: 5),
      nextScreen: FaceDetectionPage(),
    );
  }
}
