import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class MessagesListener {
  MessagesListener._();

  static void call(BuildContext context, ReceivedNearbyMessage message) {
    final senderSubtitle = 'From ${message.sender.displayName} '
        '(ID: ${message.sender.id})';
    message.content.byType(
      onTextRequest: (textRequest) {
        AppShackBar.show(
          Scaffold.of(context).context,
          '${textRequest.value} (Message ID=${textRequest.id})',
          subtitle: senderSubtitle,
        )?.closed.whenComplete(() {
          // mark as read
          context.read<AppService>().sendTextResponse(textRequest.id);
        });
      },
      onTextResponse: (textResponse) {
        AppShackBar.show(
          Scaffold.of(context).context,
          'Your message with ID=${textResponse.id} was delivered to ${message.sender.displayName}',
        );
      },
      onFilesRequest: (filesRequest) {
        ActionDialog.show(
          context,
          title: 'Request to send ${filesRequest.files.length} files',
          subtitle: senderSubtitle,
        ).then(
          // accept or dismiss the files request
          (isAccepted) => context.read<AppService>().sendFilesResponse(
                filesRequest.id,
                isAccepted: isAccepted ?? false,
              ),
        );
      },
      onFilesResponse: (filesResponse) {
        AppShackBar.show(
          Scaffold.of(context).context,
          filesResponse.isAccepted
              ? 'Request is accepted!'
              : 'Request was denied :(',
          subtitle: senderSubtitle,
          actionType:
              filesResponse.isAccepted ? ActionType.idle : ActionType.warning,
        );
      },
    );
  }
}
