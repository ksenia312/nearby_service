import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? actionName,
    VoidCallback? onAcceptAction,
  }) async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        if (subtitle != null) Text(subtitle),
      ],
    );
    final action = onAcceptAction != null && actionName != null
        ? SnackBarAction(label: actionName, onPressed: onAcceptAction)
        : null;
    final messenger = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        action: action,
        duration: Duration(seconds: action != null ? 10 : 2),
      ),
    );
    return messenger.closed.then((value) => null);
  }
}
