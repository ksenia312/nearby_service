import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

class ConnectedDeviceView extends StatelessWidget {
  const ConnectedDeviceView({
    super.key,
    required this.device,
    required this.onDisconnect,
  });

  final NearbyDevice device;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.blueAccent),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            device.info.displayName,
            style: const TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: onDisconnect,
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
