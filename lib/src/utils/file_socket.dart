import 'dart:io';
import 'dart:math';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class FilesSocket {
  FilesSocket.startListening({
    required this.content,
    required WebSocket socket,
    required NearbyServiceFilesListener? listener,
    required void Function(FilesSocket) onDestroy,
  }) : _socket = socket {
    _socket.listen(
      (event) async {
        if (event is List<int>) {
          saveChunk(event);
        } else if (event == finishCommand) {
          final file = await getFile().whenComplete(
            () {
              onDestroy(this);
            },
          );
          Logger.info('File ${file.content.fileName} was created');
          listener?.onData.call(file);
        }
      },
      onError: listener?.onError,
      cancelOnError: listener?.cancelOnError,
      onDone: listener?.onDone,
    );
    listener?.onCreated?.call();
  }

  static const _finishCommand = '@@FINISH_SENDING_FILE_';

  static String generateFinishCommand(String id) {
    return '$_finishCommand$id';
  }

  final WebSocket _socket;
  final NearbyMessageFileContent content;
  final _bytes = <int>[];

  int chunksCount = 0;

  String get finishCommand => '$_finishCommand${content.id}';

  void sendData(dynamic event) {
    _socket.add(event);
  }

  void saveChunk(List<int> value) {
    _bytes.addAll(value);
    chunksCount = chunksCount + 1;
    final logStep = min(pow(10, chunksCount.toString().length - 1), 100);
    if (chunksCount % logStep == 0) {
      Logger.debug('Got $chunksCount chunks for the file ${content.fileName}');
    }
  }

  Future<NearbyFile> getFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${content.fileName}');

      await file.writeAsBytes(_bytes);
      return NearbyFile(file: file, content: content);
    } catch (e) {
      Logger.error(e);
      rethrow;
    }
  }

  Future<void> close() => _socket.close();
}
