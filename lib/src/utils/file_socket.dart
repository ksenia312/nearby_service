import 'dart:async';
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
          addChunk(event);
        } else if (event == separateCommandOf(_currentFileIndex)) {
          _futures.add(_createFile(_currentFileIndex));
          _currentFileIndex = _currentFileIndex + 1;
          _bytesTable['$_currentFileIndex'] = [];
        } else if (event == finishCommand) {
          await Future.wait(_futures);
          Logger.info('Files pack ${content.id} was created');
          listener?.onData.call(_files);
          onDestroy(this);
        }
      },
      onError: listener?.onError,
      cancelOnError: listener?.cancelOnError,
      onDone: listener?.onDone,
    );
    listener?.onCreated?.call();
  }

  static const finishCommand = '_@@FINISH_SENDING_FILE_';

  static const separateCommand = '_@@SEPARATE_SENDING_FILE_';

  static String separateCommandOf(int index) => '$separateCommand$index';

  final NearbyMessageFilesContent content;

  final WebSocket _socket;
  final _files = <NearbyFile>[];
  final _bytesTable = <String, List<int>>{'0': []};
  final _futures = <Future>[];

  int _chunksCount = 0;
  int _currentFileIndex = 0;

  void sendData(dynamic event) {
    _socket.add(event);
  }

  void addChunk(List<int> value) {
    _bytesTable['$_currentFileIndex']?.addAll(value);
    _chunksCount = _chunksCount + 1;
    final logStep = min(pow(10, _chunksCount.toString().length - 1), 100);
    if (_chunksCount % logStep == 0) {
      Logger.debug(
        'Got $_chunksCount chunks for the file ${content.files[_currentFileIndex].name}',
      );
    }
  }

  Future<void> _createFile(int index) async {
    try {
      final bytes = _bytesTable['$index']!;
      final fileInfo = content.files[index];
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${fileInfo.name}');

      await file.writeAsBytes(bytes);

      final nearbyFile = NearbyFile(file: file, info: fileInfo);
      _files.add(nearbyFile);

      Logger.info('File ${nearbyFile.info.name} was created');
    } catch (e) {
      Logger.error(e);
    }
  }

  Future<void> close() => _socket.close();
}
