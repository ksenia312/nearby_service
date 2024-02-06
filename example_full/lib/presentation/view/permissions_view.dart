import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, service, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionButton(
            onTap: service.requestPermissions,
            title: 'Request permissions',
          ),
        ],
      );
    });
  }
}
