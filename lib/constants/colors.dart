import 'package:flutter/material.dart';

class MyColor{

  static const Color brownOne = Color(0xff342e28);
  static const Color offWhite = Color(0xffd8c7c3);
  static const Color myBrown = Color(0xffb6976f);
  static const Color myBrownGray = Color(0xff464643);
  static const Color accentBrown = Color(0xff7d6a59);


}
final lightTheme = ThemeData(
  colorScheme: ThemeData.light().colorScheme.copyWith(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Color(0xffb26442),
    onSecondary: Colors.white,

  ),
);

/*
old colors:
class MyColor{

  static const Color myOrange = Color(0xffec6433);
  static const Color offWhite = Color(0xffe2d6cb);
  static const Color myBrown = Color(0xffb26442);
  static const Color myBrownGray = Color(0xff464643);

}
final lightTheme = ThemeData(
  colorScheme: ThemeData.light().colorScheme.copyWith(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.deepOrange,
    onSecondary: Colors.white,
  ),
);

 */