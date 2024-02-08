import 'package:flutter/material.dart';

class IOSRoleSelector extends StatelessWidget {
  const IOSRoleSelector({
    super.key,
    required this.isIosBrowser,
    required this.onSelect,
  });

  final bool isIosBrowser;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            'You are ${isIosBrowser ? 'Browser' : 'Advertiser'}',
          ),
        ),
        Switch(
          value: isIosBrowser,
          onChanged: onSelect,
        ),
      ],
    );
  }
}
