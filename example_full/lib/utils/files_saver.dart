import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:path_provider/path_provider.dart';

class FilesSaver {
  FilesSaver._();

  static bool isImage(String? extension) {
    return _imageExtensions.contains(extension?.toLowerCase());
  }

  static const _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  ];

  static Future<List<NearbyFileInfo>> savePack(
      ReceivedNearbyFilesPack pack) async {
    final files = <NearbyFileInfo>[];
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
      files.add(NearbyFileInfo(path: newFile.path));
    }
    return files;
  }
}
