part of 'nearby_socket_service.dart';

class FileSocketsManager {
  FileSocketsManager(this._network, this._service);

  final NearbyServiceNetwork _network;
  final NearbyAndroidService _service;
  final _filesSockets = <FilesSocket>[];
  final _serverWaitingContents = <String, HttpRequest>{};

  NearbyServiceFilesListener? _filesListener;

  void setListener(NearbyServiceFilesListener? listener) {
    _filesListener = listener;
  }

  void onWsRequest(HttpRequest request) {
    final type = NearbySocketType.fromRequest(request);
    final fileId = NearbyFileId.fromRequest(request);
    if (type == NearbySocketType.file && fileId != null) {
      _serverWaitingContents[fileId] = request;
    }
  }

  Future<void> handleFileMessageContent(
    NearbyMessageFilesContent content, {
    required NearbyAndroidCommunicationChannelData androidData,
    required bool isReceived,
  }) async {
    final info = await _service.getConnectionInfo();
    if (info != null && info.groupFormed) {
      if (info.isGroupOwner) {
        await _handleServerFileContent(content);
        if (content is NearbyMessageFileResponse && isReceived) {
          await _tryTransferData(content);
        }
      } else {
        await _handleClientFileContent(
          content,
          connectionData: androidData,
          ownerIpAddress: info.ownerIpAddress,
        );
        if (content is NearbyMessageFileRequest && !isReceived) {
          await _tryTransferData(content);
        }
      }
    }
  }

  Future<void> closeAll() async {
    for (final fileSocket in _filesSockets) {
      await fileSocket.close();
    }
    _filesSockets.clear();
    _filesListener = null;
  }

  Future<void> _handleClientFileContent(
    NearbyMessageFilesContent content, {
    required NearbyAndroidCommunicationChannelData connectionData,
    required String ownerIpAddress,
  }) async {
    try {
      final shouldStartFileSocket = content.byType(
            onFileResponse: (response) => response.response,
            onFileRequest: (request) => true,
          ) ??
          false;
      if (shouldStartFileSocket) {
        final socket = await _network.connectToSocket(
          ownerIpAddress: ownerIpAddress,
          port: connectionData.port,
          socketType: NearbySocketType.file,
          headers: {
            NearbyFileId.key: content.id,
          },
        );

        if (socket != null) {
          _filesSockets.add(
            FilesSocket.startListening(
              content: content,
              socket: socket,
              listener: _filesListener,
              onDestroy: _filesSockets.remove,
            ),
          );
          Logger.info(
            'The file socket was created for the files pack ${content.id}',
          );
        } else {
          await Future.delayed(
            connectionData.clientReconnectInterval,
            () => _handleClientFileContent(
              content,
              connectionData: connectionData,
              ownerIpAddress: ownerIpAddress,
            ),
          );
        }
      }
    } catch (e) {
      Logger.error(e);
    }
  }

  Future<void> _handleServerFileContent(
    NearbyMessageFilesContent content,
  ) async {
    MapEntry<String, HttpRequest>? request;
    try {
      request = _serverWaitingContents.entries.firstWhere(
        (element) => element.key == content.id,
      );
    } catch (e) {
      request = null;
    }

    if (request != null) {
      Logger.debug('Found cached server file request ${request.key}');
      _filesSockets.add(
        FilesSocket.startListening(
          content: content,
          socket: await WebSocketTransformer.upgrade(request.value),
          listener: _filesListener,
          onDestroy: _filesSockets.remove,
        ),
      );
      _serverWaitingContents.remove(content.id);
      Logger.info('Created a socket for the files pack ${content.id}');
    }
  }

  Future<void> _tryTransferData(NearbyMessageFilesContent content) async {
    Logger.debug('Start transferring the files pack ${content.id}');
    final filesSocket = _find(content.id);
    if (filesSocket != null) {
      for (var i = 0; i < content.files.length; i++) {
        try {
          final fileInfo = content.files[i];
          await _streamFile(
            content.id,
            filesSocket: filesSocket,
            file: File(fileInfo.path),
          )?.asFuture();

          filesSocket.sendData(FilesSocket.separateCommandOf(i));
          Logger.debug('Sent separate command for file №$i');
        } catch (e) {
          Logger.error(e);
          continue;
        }
      }
      filesSocket.sendData(FilesSocket.finishCommand);
      Logger.debug('Sent finish command for the pack ${content.id}');
    }
  }

  StreamSubscription? _streamFile(
    String id, {
    required FilesSocket filesSocket,
    required File file,
  }) {
    return file.openRead().listen(
      (data) {
        filesSocket.sendData(data);
      },
    );
  }

  FilesSocket? _find(String id) {
    FilesSocket? fileSocket;
    try {
      fileSocket = _filesSockets.firstWhere(
        (element) => element.content.id == id,
      );
    } catch (e) {
      fileSocket = null;
    }
    return fileSocket;
  }
}
