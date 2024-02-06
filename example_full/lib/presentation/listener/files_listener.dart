import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';

class FilesListener {
  FilesListener._();

  static void call(BuildContext context, ReceivedNearbyFilesPack pack) {
    final senderSubtitle = 'From ${pack.sender.displayName} '
        '(ID: ${pack.sender.id})';
    AppShackBar.show(
      Scaffold.of(context).context,
      '${pack.files.length} files saved! \n${pack.files.map((e) => e.name).join('\n')}',
      subtitle: senderSubtitle,
    );
  }
}
