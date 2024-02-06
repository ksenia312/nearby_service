import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

import '../components/device_preview.dart';

class StreamingPeersView extends StatelessWidget {
  const StreamingPeersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          type: ActionType.warning,
          onTap: context.read<AppService>().stopListeningPeers,
          title: 'Stop stream peers',
        ),
        const SizedBox(height: 10),
        const _PeersBody(),
      ],
    );
  }
}

class _PeersBody extends StatelessWidget {
  const _PeersBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, service, _) {
        return (service.peers != null && service.peers!.isNotEmpty)
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...service.peers!.map(
                    (e) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: DevicePreview(device: e),
                      );
                    },
                  ),
                ],
              )
            : Text(
                Platform.isAndroid || service.isIOSBrowser
                    ? 'No one here ('
                    : "Wait until someone invites you!",
                textAlign: TextAlign.center,
              );
      },
    );
  }
}
