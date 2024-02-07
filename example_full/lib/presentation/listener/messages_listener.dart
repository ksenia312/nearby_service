import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';

class MessagesListener {
  MessagesListener._();

  static void call(
    BuildContext context, {
    required AppService service,
    required ReceivedNearbyMessage message,
  }) {
    final senderSubtitle = 'From ${message.sender.displayName} '
        '(ID: ${message.sender.id})';
    message.content.byType(
      onTextRequest: (textRequest) {
        AppShackBar.show(
          context,
          '${textRequest.value} (Message ID=${textRequest.id})',
          subtitle: senderSubtitle,
        )?.closed.whenComplete(() {
          // mark as read
          service.sendTextResponse(textRequest.id);
        });
      },
      onTextResponse: (textResponse) {
        AppShackBar.show(
          context,
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
          (isAccepted) => service.sendFilesResponse(
            filesRequest,
            isAccepted: isAccepted ?? false,
          ),
        );
      },
      onFilesResponse: (filesResponse) {
        AppShackBar.show(
          context,
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
