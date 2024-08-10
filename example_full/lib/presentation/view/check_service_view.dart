import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class CheckServiceView extends StatefulWidget {
  const CheckServiceView({super.key});

  @override
  State<CheckServiceView> createState() => _CheckServiceViewState();
}

class _CheckServiceViewState extends State<CheckServiceView> {
  bool showEnableButton = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: () {
            context.read<AppService>().checkWifiService().then((value) {
              if (!value) {
                setState(() {
                  showEnableButton = true;
                });
                if (context.mounted) {
                  AppShackBar.show(
                    context,
                    'Please enable Wi-fi',
                    actionType: ActionType.warning,
                  );
                }
              }
            });
          },
          title: 'Check Wi-fi service',
        ),
        if (showEnableButton)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ActionButton(
              onTap: context.read<AppService>().openServicesSettings,
              title: 'Open settings',
            ),
          ),
      ],
    );
  }
}
