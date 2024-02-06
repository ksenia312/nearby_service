import 'package:flutter/material.dart';

import 'action_button.dart';

class AppShackBar {
  AppShackBar._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context,
    String title, {
    String? subtitle,
    ActionType actionType = ActionType.idle,
  }) {
    return ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: RichText(
          text: TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              if (subtitle != null)
                TextSpan(
                  text: '\n$subtitle',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 20,
        ),
        backgroundColor: actionType.color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
