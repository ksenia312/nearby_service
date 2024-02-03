part of 'nearby_socket_service.dart';

class FileSocketsManager {
  FileSocketsManager(this._network, this._service, this._pingManager);

  final NearbyServiceNetwork _network;
  final NearbyAndroidService _service;
  final NearbySocketPingManager _pingManager;

  final _filesSockets = <String, FilesSocket>{};
  final _serverWaitingRequests = <String, HttpRequest>{};

  NearbyServiceFilesListener? _filesListener;

  void setListener(NearbyServiceFilesListener? listener) {
    _filesListener = listener;
  }

  void onWsRequest(HttpRequest request) {
    final type = NearbySocketType.fromRequest(request);
    final filesPackId = NearbyFilesPackId.fromRequest(request);
    if (type == NearbySocketType.file && filesPackId != null) {
      _serverWaitingRequests[filesPackId] = request;
    }
  }

  Future<void> handleFileMessageContent(
    NearbyMessageFilesContent content, {
    required NearbyAndroidCommunicationChannelData androidData,
    required bool isReceived,
  }) async {
    final shouldStartSocket = content.byType(
          onFilesResponse: (response) => response.response,
          onFilesRequest: (_) => true,
        ) ??
        false;

    if (shouldStartSocket) {
      final info = await _service.getConnectionInfo();
      if (info != null && info.groupFormed) {
        if (info.isGroupOwner) {
          await _startFilesServer(content);
          if (content is NearbyMessageFilesResponse && isReceived) {
            await _tryTransferData(content);
          }
        } else {
          await _connectToFilesSocket(
            content,
            connectionData: androidData,
            ownerIpAddress: info.ownerIpAddress,
          );
          if (content is NearbyMessageFilesRequest && !isReceived) {
            await _tryTransferData(content);
          }
        }
      }
    } else {
      _filesSockets.remove(content.id);
    }
  }

  Future<void> closeAll() async {
    for (final fileSocket in _filesSockets.values) {
      await fileSocket.close();
    }
    _filesSockets.clear();
    _filesListener = null;
  }

  Future<void> _connectToFilesSocket(
    NearbyMessageFilesContent content, {
    required NearbyAndroidCommunicationChannelData connectionData,
    required String ownerIpAddress,
  }) async {
    try {
      final response = await _network.pingServer(
        address: ownerIpAddress,
        port: connectionData.port,
      );
      if (await _pingManager.checkPong(response)) {
        await _tryStartFileSocket(
          content,
          onCreateSocket: () => _network.connectToSocket(
            ownerIpAddress: ownerIpAddress,
            port: connectionData.port,
            socketType: NearbySocketType.file,
            headers: {
              NearbyFilesPackId.key: content.id,
            },
          ),
        );
      } else {
        Logger.debug(
          'Files server is unavailable, reconnect in ${connectionData.clientReconnectInterval}s',
        );
        await Future.delayed(
          connectionData.clientReconnectInterval,
          () => _connectToFilesSocket(
            content,
            connectionData: connectionData,
            ownerIpAddress: ownerIpAddress,
          ),
        );
      }
    } catch (e) {
      Logger.error(e);
    }
  }

  Future<void> _startFilesServer(
    NearbyMessageFilesContent content,
  ) async {
    final request = _serverWaitingRequests[content.id];

    if (request != null) {
      Logger.debug('Found cached server file request ${content.id}');

      final result = await _tryStartFileSocket(
        content,
        onCreateSocket: () => WebSocketTransformer.upgrade(request),
      );
      if (result) {
        _serverWaitingRequests.remove(content.id);
      }
    }
  }

  Future<bool> _tryStartFileSocket(
    NearbyMessageFilesContent content, {
    required Future<WebSocket?> Function() onCreateSocket,
  }) async {
    final socket = await onCreateSocket();
    if (socket != null) {
      _filesSockets[content.id] = FilesSocket.startListening(
        content: content,
        socket: socket,
        listener: _filesListener,
        onDestroy: _filesSockets.remove,
      );
      Logger.info('Created a socket for the files pack ${content.id}');
      return true;
    }
    return false;
  }

  Future<void> _tryTransferData(NearbyMessageFilesContent content) async {
    final filesSocket = _filesSockets[content.id];
    if (filesSocket != null) {
      Logger.debug('Start transferring the files pack ${content.id}');
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
    return file.openRead().listen(filesSocket.sendData);
  }
}
