import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class FilesSocket {
  FilesSocket.startListening({
    required this.sender,
    required this.filesRequest,
    required this.listener,
    required this.onDestroy,
    required WebSocket socket,
  }) : _socket = socket {
    _socket.listen(
      _listener,
      onError: listener?.onError,
      cancelOnError: listener?.cancelOnError,
      onDone: listener?.onDone,
    );
    listener?.onCreated?.call();
  }

  static const finishCommand = '_@@FINISH_SENDING_FILES_';

  static const separateCommand = '_@@SEPARATE_SENDING_FILE_';

  static String separateCommandOf(int index) => '$separateCommand$index';

  final NearbyMessageFilesRequest filesRequest;
  final void Function(String) onDestroy;
  final NearbyServiceFilesListener? listener;
  final NearbyDeviceInfo sender;
  final WebSocket _socket;

  final _files = <NearbyFileInfo>[];
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
        'Got $_chunksCount chunks for the file ${filesRequest.files[_currentFileIndex].name}',
      );
    }
  }

  Future<void> _listener(dynamic event) async {
    if (event is List<int>) {
      addChunk(event);
    } else if (event == separateCommandOf(_currentFileIndex)) {
      _futures.add(_createFile(_currentFileIndex));
      Logger.info('Completed receiving file №${_currentFileIndex + 1}');
      _currentFileIndex = _currentFileIndex + 1;
      _chunksCount = 0;
      _bytesTable['$_currentFileIndex'] = [];
    } else if (event == finishCommand) {
      await Future.wait(_futures);
      Logger.info('Files pack ${filesRequest.id} was created');

      listener?.onData.call(
        ReceivedNearbyFilesPack(
          id: filesRequest.id,
          sender: sender,
          files: _files,
        ),
      );
      onDestroy(filesRequest.id);
    }
  }

  Future<void> _createFile(int index) async {
    try {
      final bytes = _bytesTable['$index']!;
      final fileInfo = filesRequest.files[index];
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${fileInfo.name}');
      await file.writeAsBytes(bytes);
      final updatedFileInfo = NearbyFileInfo(path: file.path);

      _files.add(updatedFileInfo);

      Logger.info('File ${updatedFileInfo.name} was created');
    } catch (e) {
      Logger.error(e);
    }
  }

  Future<void> close() => _socket.close();
}
