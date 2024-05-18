import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/presentation/app.dart';
import 'package:provider/provider.dart';

class DevicePreview extends StatelessWidget {
  const DevicePreview({
    super.key,
    required this.device,
    this.largeView = false,
  });

  final NearbyDevice device;
  final bool largeView;

  @override
  Widget build(BuildContext context) {
    final color = device.status.isConnected ? kGreenColor : kGreyColor;

    final avatar = CircleAvatar(
      backgroundColor: kBlueColor.withOpacity(0.7),
      foregroundColor: kWhiteColor,
      maxRadius: largeView ? 100 : 30,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          device.info.displayName.substring(0, 1).toUpperCase(),
          style: TextStyle(fontSize: largeView ? 32 : 16),
        ),
      ),
    );
    final name = Text(
      '${device.info.displayName} '
      '${device.byPlatform(onAndroid: (d) => d.isGroupOwner ? " - group owner" : "") ?? ''}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
    final id = Text(
      'ID: ${device.info.id}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
          ),
    );
    final status = Text(
      device.byPlatform(
            onAny: (d) => d.status.name,
            onIOS: (d) =>
                context.select<AppService, bool>((v) => v.isIOSBrowser)
                    ? "Peer found | ${d.status.name}"
                    : "Pending invitation | ${d.status.name}",
          ) ??
          '',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
          ),
    );

    final trailingButton = device.status.isConnected
        ? TextButton(
            onPressed: () => context.read<AppService>().disconnect(device),
            style: TextButton.styleFrom(
              foregroundColor: kPinkColor,
            ),
            child: const Text('Disconnect'),
          )
        : null;
    if (largeView) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(height: 10),
          name,
          const SizedBox(height: 5),
          id,
          if (trailingButton != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: trailingButton,
            ),
        ],
      );
    } else {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (device.status.isConnecting) {
            context.read<AppService>().cancelConnect();
          } else if (!device.status.isConnected) {
            context.read<AppService>().connect(device);
          } else {
            context.read<AppService>().startListeningConnectedDevice(device);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    avatar,
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [name, id, status],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  device.status.isConnected
                      ? 'Tap to chat'
                      : device.status.isConnecting
                          ? 'Tap to cancel connection'
                          : 'Tap to connect',
                  style: const TextStyle(color: kGreenColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
