import 'package:flutter/material.dart';
import 'package:rafiqi/screens/splash_screen.dart';
import 'constants/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
class App extends StatelessWidget  {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
    );
  }
}
