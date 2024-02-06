import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: context.read<AppService>().startListeningPeers,
          title: 'Tap to get peers!',
        ),
        const SizedBox(height: 10),
        ActionButton(
          type: ActionType.warning,
          onTap: context.read<AppService>().stopDiscovery,
          title: 'Stop discovery',
        ),
      ],
    );
  }
}
