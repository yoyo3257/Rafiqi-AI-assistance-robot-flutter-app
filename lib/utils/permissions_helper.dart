import 'dart:ui';

import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<void> checkMicrophonePermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      print("Microphone permission granted.");
      onGranted?.call();
    } else {
      print("Microphone permission denied.");
      onDenied?.call();
    }
  }
}