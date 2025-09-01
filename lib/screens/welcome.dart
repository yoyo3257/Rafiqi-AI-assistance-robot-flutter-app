import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafiqi/constants/colors.dart';
import 'package:rafiqi/screens/chat_page.dart';
import 'package:rafiqi/screens/voice_chat_screen.dart';
import 'multi_floor_map.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/voiceBackground.png'),
        context,
      );
      precacheImage(
          const AssetImage('assets/images/chat_background.jpg'), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.offWhite,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: MyColor.offWhite,
          image: DecorationImage(
              image: AssetImage('assets/images/welcome_background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.7),
        ),
        child: Column(
          verticalDirection: VerticalDirection.up,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VoiceChatScreen2()));
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MyColor.brownOne),
                    foregroundColor: WidgetStatePropertyAll(MyColor.offWhite),
                    fixedSize: WidgetStatePropertyAll(
                      Size(250, 100),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  child: const Icon(CupertinoIcons.mic_fill, size: 60),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  const ChatPage()));
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MyColor.brownOne),
                    foregroundColor: WidgetStatePropertyAll(MyColor.offWhite),
                    fixedSize: WidgetStatePropertyAll(
                      Size(250, 100),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  child:
                      const Icon(CupertinoIcons.chat_bubble_2_fill, size: 60),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MultiFloorMap()));
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MyColor.brownOne),
                    foregroundColor: WidgetStatePropertyAll(MyColor.offWhite),
                    fixedSize: WidgetStatePropertyAll(
                      Size(250, 100),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  child: const Icon(
                    Icons.map_sharp,
                    size: 60,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'كيف يمكنني مساعدتك؟',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 80,
                color: MyColor.brownOne,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(5.0, 5.0),
                    color: MyColor.offWhite,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'How Can I Help You?',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 80,
                color: MyColor.brownOne,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(5.0, 5.0),
                    color: MyColor.offWhite,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
