import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/uikit/action_button.dart';

class ActionDialog {
  ActionDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: [
            ActionButton(
              onTap: () => Navigator.of(context).pop(true),
              title: 'Yes',
            ),
            ActionButton(
              onTap: () => Navigator.of(context).pop(false),
              title: 'No',
              type: ActionType.warning,
            ),
          ],
        );
      },
    );
  }
}
