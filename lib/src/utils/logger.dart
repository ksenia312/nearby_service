import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

class Logger {
  Logger._();

  static NearbyServiceLogLevel level =
      kDebugMode ? NearbyServiceLogLevel.debug : NearbyServiceLogLevel.error;

  static void debug(String message) {
    if (level.index <= NearbyServiceLogLevel.debug.index) {
      debugPrint(
        _messageWrapper(
          message,
          androidColor: AndroidConsoleColor.grey,
          iosIcon: IOSConsoleIcon.settings,
        ),
      );
    }
  }

  static void info(String message) {
    if (level.index <= NearbyServiceLogLevel.info.index) {
      debugPrint(
        _messageWrapper(
          message,
          androidColor: AndroidConsoleColor.green,
          iosIcon: IOSConsoleIcon.success,
        ),
      );
    }
  }

  static void error(Object? error) {
    if (level.index <= NearbyServiceLogLevel.error.index) {
      debugPrint(
        _messageWrapper(
          '$error',
          androidColor: AndroidConsoleColor.red,
          iosIcon: IOSConsoleIcon.error,
        ),
      );
    }
  }

  static String _messageWrapper(
    String message, {
    required AndroidConsoleColor androidColor,
    required IOSConsoleIcon iosIcon,
  }) {
    if (Platform.isAndroid) {
      return '\x1B[${androidColor.value}m[NearbyService]: $message\x1B[0m';
    }
    if (Platform.isIOS) {
      return '[NearbyService ${iosIcon.value}]: $message ';
    }
    return message;
  }
}

enum AndroidConsoleColor {
  grey(37),
  green(32),
  red(31);

  const AndroidConsoleColor(this.value);

  final int value;
}

enum IOSConsoleIcon {
  settings('🛠'),
  success('✅'),
  error('❌');

  const IOSConsoleIcon(this.value);

  final String value;
}
