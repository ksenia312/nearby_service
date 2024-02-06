import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

import '../components/device_preview.dart';

class ConnectedView extends StatelessWidget {
  const ConnectedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, service, _) {
        final device = service.connectedDevice;
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
                    if (service.communicationChannelState !=
                        CommunicationChannelState.loading)
                      ActionButton(
                        title: 'Start communicate',
                        onTap: () => service.startCommunicationChannel(
                          listener: (event) => _listener(context, event),
                          onFilesSaved: (files) => _onFileSaved(context, files),
                        ),
                      )
                    else
                      Text(
                        'Connecting socket.. '
                        '${service.isAndroidGroupOwner != null ? service.isAndroidGroupOwner! ? "Waiting a client for connect" : "Waiting a server for connect" : "Waiting a connection"}',
                      )
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }

  void _listener(BuildContext context, ReceivedNearbyMessage message) {
    final senderSubtitle = 'From ${message.sender.displayName} '
        '(ID: ${message.sender.id})';
    message.content.byType(
      onText: (content) {
        AppShackBar.show(
          Scaffold.of(context).context,
          content.value,
          subtitle: senderSubtitle,
        );
      },
      onFilesRequest: (content) {
        ActionDialog.show(
          context,
          title: 'Request to send ${content.files.length} files',
          subtitle: senderSubtitle,
        ).then((value) {
          if (value is bool) {
            context.read<AppService>().sendFilesResponse(
                  content.id,
                  response: value,
                );
          }
        });
      },
      onFilesResponse: (content) {
        AppShackBar.show(
          Scaffold.of(context).context,
          content.response ? 'Request is accepted!' : 'Request was denied :(',
          subtitle: senderSubtitle,
          actionType: content.response ? ActionType.idle : ActionType.warning,
        );
      },
    );
  }

  void _onFileSaved(BuildContext context, ReceivedNearbyFilesPack pack) {
    final senderSubtitle = 'From ${pack.sender.displayName} '
        '(ID: ${pack.sender.id})';
    AppShackBar.show(
      Scaffold.of(context).context,
      '${pack.files.length} files saved! \n${pack.files.map((e) => e.name).join('\n')}',
      subtitle: senderSubtitle,
    );
  }
}
