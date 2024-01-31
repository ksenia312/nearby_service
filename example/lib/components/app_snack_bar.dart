import 'package:flutter/material.dart';

class AppShackBar {
  AppShackBar._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    return ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: RichText(
          text: TextSpan(
            text: '$title \n',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              if (subtitle != null)
                TextSpan(
                  text: subtitle,
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
        backgroundColor: Colors.pink.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
