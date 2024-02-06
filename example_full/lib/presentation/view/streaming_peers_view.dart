import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
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
    return Selector<AppService, bool>(
      selector: (context, service) => service.isIOSBrowser,
      builder: (context, isIOSBrowser, _) {
        return Selector<AppService, List<NearbyDevice>?>(
          selector: (context, service) => service.peers,
          builder: (context, peers, _) {
            return (peers != null && peers.isNotEmpty)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...peers.map(
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
                    Platform.isAndroid || isIOSBrowser
                        ? 'No one here ('
                        : "Wait until someone invites you!",
                    textAlign: TextAlign.center,
                  );
          },
        );
      },
    );
  }
}
