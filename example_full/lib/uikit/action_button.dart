import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/presentation/app.dart';

enum ActionType {
  idle(kBlueColor),
  warning(kPinkColor),
  success(kGreenColor);

  const ActionType(this.color);

  final Color color;
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onTap,
    required this.title,
    this.type = ActionType.idle,
  });

  final VoidCallback onTap;
  final String title;
  final ActionType type;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        maximumSize: const Size(150, 50),
        minimumSize: const Size(70, 50),
        elevation: 2,
        surfaceTintColor: type.color.withOpacity(0.05),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: type.color,
              height: 1,
            ),
      ),
    );
  }
}
