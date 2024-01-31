part of '../main.dart';

enum _ActionButtonType {
  idle(Color(0xFF00C853)),
  warning(Color(0xFFD50000));

  const _ActionButtonType(this.color);

  final Color color;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    required this.title,
    this.type = _ActionButtonType.idle,
  });

  final VoidCallback onTap;
  final String title;
  final _ActionButtonType type;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        maximumSize: const Size(150, 70),
        minimumSize: const Size(70, 70),
        elevation: 3,
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
