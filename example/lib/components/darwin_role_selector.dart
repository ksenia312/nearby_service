import 'package:flutter/material.dart';

class DarwinRoleSelector extends StatelessWidget {
  const DarwinRoleSelector({
    super.key,
    required this.isDarwinBrowser,
    required this.onSelect,
  });

  final bool isDarwinBrowser;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            'You are ${isDarwinBrowser ? 'Browser' : 'Advertiser'}',
          ),
        ),
        Switch(
          value: isDarwinBrowser,
          onChanged: onSelect,
        ),
      ],
    );
  }
}
