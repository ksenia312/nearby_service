import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:path_provider/path_provider.dart';

class FilesSaver {
  FilesSaver._();

  static Future<bool> savePack(
    ReceivedNearbyFilesPack pack,
  ) async {
    final directory = Platform.isAndroid
        ? Directory('storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    for (final nearbyFile in pack.files) {
      final newFile = await File(nearbyFile.path).copy(
        '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.${nearbyFile.extension}',
      );
      if (!await newFile.exists()) {
        await newFile.create();
      }
    }
    return true;
  }
}
