import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

class PeerWidget extends StatelessWidget {
  const PeerWidget({
    super.key,
    required this.device,
    required this.isIosBrowser,
    required this.onConnect,
  });

  final NearbyDevice device;
  final bool isIosBrowser;
  final ValueChanged<NearbyDevice> onConnect;

  @override
  Widget build(BuildContext context) {
    final status =
        device.status.isConnected ? 'Tap to chat' : device.status.name;
    return ListTile(
      title: Text(
        '${isIosBrowser ? 'Found device' : 'Pending invitation'} | ${device.info.displayName} | $status',
      ),
      onTap: () => onConnect(device),
      tileColor: Colors.blueAccent,
      textColor: Colors.white,
    );
  }
}
