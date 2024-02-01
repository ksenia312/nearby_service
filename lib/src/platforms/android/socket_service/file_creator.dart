import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:path_provider/path_provider.dart';

class FileCreator {
  FileCreator({required this.content});

  static const _finishCommand = '@@FINISH_SENDING_FILE_';

  static String generateFinishCommand(String id) {
    return '$_finishCommand$id';
  }

  final NearbyMessageFileContent content;
  final _bytes = <int>[];

  String get finishCommand => '$_finishCommand${content.id}';

  void add(List<int> value) {
    _bytes.addAll(value);
  }

  Future<NearbyFile> getFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${content.fileName}');

    await file.writeAsBytes(_bytes);
    return NearbyFile(file: file, content: content);
  }
}
