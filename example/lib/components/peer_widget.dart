import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

class PeerWidget extends StatelessWidget {
  const PeerWidget({
    super.key,
    required this.device,
    required this.isDarwinBrowser,
    required this.onConnect,
    required this.communicationChannelState,
  });

  final NearbyDevice device;
  final bool isDarwinBrowser;
  final ValueChanged<NearbyDevice> onConnect;
  final CommunicationChannelState communicationChannelState;

  @override
  Widget build(BuildContext context) {
    final connectedStateCaption = communicationChannelState.isLoading
        ? 'Wait for connection'
        : 'Tap to chat';

    final status =
        device.status.isConnected ? connectedStateCaption : device.status.name;

    final canTap = !communicationChannelState.isLoading;

    return ListTile(
      title: Text(
        '${isDarwinBrowser ? 'Found device' : 'Pending invitation'} | ${device.info.displayName} | $status',
      ),
      onTap: canTap ? () => onConnect(device) : null,
      tileColor: Colors.blueAccent,
      textColor: Colors.white,
    );
  }
}
