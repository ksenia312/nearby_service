import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/presentation/listener/files_listener.dart';
import 'package:nearby_service_example_full/presentation/listener/messages_listener.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

import '../components/device_preview.dart';

class ConnectedView extends StatelessWidget {
  const ConnectedView({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final device = context.select<AppService, NearbyDevice?>(
      (service) => service.connectedDevice,
    );
    final isAndroidGroupOwner = context.select<AppService, bool?>(
      (service) => service.isAndroidGroupOwner,
    );
    final communicationChannelState =
        context.select<AppService, CommunicationChannelState>(
      (service) => service.communicationChannelState,
    );

    final service = context.read<AppService>();
    return device != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!device.status.isConnected)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Connection lost'),
                    ),
                  )
                else if (!device.status.isConnected)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Connection lost'),
                      ActionButton(
                        onTap: () {
                          service.connect(device);
                        },
                        title: 'Reconnect',
                      ),
                    ],
                  )
                else
                  DevicePreview(device: device, largeView: true),
                const SizedBox(height: 10),
                if (!communicationChannelState.isLoading)
                  ActionButton(
                    title: 'Start communicate',
                    onTap: () {
                      service.startCommunicationChannel(
                        listener: (event) {
                          MessagesListener.call(
                            scaffoldKey.currentState!.context,
                            service: service,
                            message: event,
                          );
                        },
                        onFilesSaved: (pack) {
                          FilesListener.call(
                            scaffoldKey.currentState!.context,
                            service: service,
                            pack: pack,
                          );
                        },
                      );
                    },
                  )
                else
                  Text(
                    'Connecting socket.. '
                    '${isAndroidGroupOwner != null ? isAndroidGroupOwner ? "Waiting a client for connect" : "Waiting a server for connect" : "Waiting a connection"}',
                  )
              ],
            ),
          )
        : const SizedBox();
  }
}
