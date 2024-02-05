import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/file_socket.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:nearby_service/src/utils/random.dart';
import 'package:nearby_service/src/utils/stream_mapper.dart';

part 'ping_manager.dart';

part 'network.dart';

part 'file_sockets_manager.dart';

///
/// A service for creating a communication channel on the Android platform.
///
class NearbySocketService {
  NearbySocketService(this._service);

  final NearbyAndroidService _service;
  final _pingManager = NearbySocketPingManager();
  final _network = NearbyServiceNetwork();
  late final _fileSocketsManager = FileSocketsManager(
    _network,
    _service,
    _pingManager,
  );

  final state = ValueNotifier(CommunicationChannelState.notConnected);

  NearbyAndroidCommunicationChannelData _androidData =
      const NearbyAndroidCommunicationChannelData();

  String? _connectedDeviceId;
  WebSocket? _socket;
  HttpServer? _server;
  StreamSubscription? _messagesSubscription;

  ///
  /// Start a socket with the user's role defined.
  /// If he is the owner of the group, he becomes a server.
  /// Otherwise, he becomes a client.
  ///
  /// * The server starts up and waits for a request from the
  /// client to establish a connection.
  /// * The client pings the server until he receives a pong.
  /// When he does, he tries to connect to the server.
  ///
  Future<bool> startSocket({
    required NearbyCommunicationChannelData data,
  }) async {
    state.value = CommunicationChannelState.loading;

    _androidData = data.androidData;
    _connectedDeviceId = data.connectedDeviceId;

    _fileSocketsManager
      ..setListener(data.filesListener)
      ..setConnectionData(data.androidData);

    final info = await _service.getConnectionInfo();

    if (info != null && info.groupFormed) {
      if (info.isGroupOwner) {
        await _startServerSubscription(
          socketListener: data.messagesListener,
          info: info,
        );
        return true;
      } else {
        await _tryConnectClient(
          socketListener: data.messagesListener,
          info: info,
        );
        return true;
      }
    }
    return false;
  }

  ///
  /// Adds [OutgoingNearbyMessage]'s JSON representation to the [_socket].
  ///
  Future<bool> send(OutgoingNearbyMessage message) async {
    if (message.isValid) {
      if (_socket != null && message.receiver.id == _connectedDeviceId) {
        final sender = await _service.getCurrentDeviceInfo();
        if (sender != null) {
          _socket!.add(
            jsonEncode(
              {
                'content': message.content.toJson(),
                'sender': sender.toJson(),
              },
            ),
          );
          _handleMessage(message);
        }
        return true;
      }
      return false;
    } else {
      throw NearbyServiceException.invalidMessage(message.content);
    }
  }

  ///
  /// Turns off [_messagesSubscription] and [_socket].
  ///
  Future<bool> cancel() async {
    try {
      await _messagesSubscription?.cancel();
      await _fileSocketsManager.closeAll();

      _messagesSubscription = null;
      _socket?.close();
      _socket = null;
      _server?.close(force: true);
      _server = null;
      _connectedDeviceId = null;

      state.value = CommunicationChannelState.notConnected;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _tryConnectClient({
    required NearbyServiceMessagesListener socketListener,
    required NearbyConnectionAndroidInfo info,
  }) async {
    final response = await _network.pingServer(
      address: info.ownerIpAddress,
      port: _androidData.port,
    );

    if (await _pingManager.checkPong(response)) {
      _socket = await _network.connectToSocket(
        ownerIpAddress: info.ownerIpAddress,
        port: _androidData.port,
        socketType: NearbySocketType.message,
      );
      _createSocketSubscription(socketListener);
    } else {
      Logger.debug(
        'Retry to connect to the server in ${_androidData.clientReconnectInterval.inSeconds}s',
      );
      Future.delayed(_androidData.clientReconnectInterval, () {
        _tryConnectClient(
          socketListener: socketListener,
          info: info,
        );
      });
    }
  }

  Future<void> _startServerSubscription({
    required NearbyServiceMessagesListener socketListener,
    required NearbyConnectionAndroidInfo info,
  }) async {
    _server = await _network.startServer(
      ownerIpAddress: info.ownerIpAddress,
      port: _androidData.port,
    );
    _server?.listen(
      (request) async {
        _androidData.serverListener?.call(request);
        final isPing = await _pingManager.checkPing(request);
        if (isPing) {
          Logger.debug('Server got ping request');
          _network.pongClient(request);
          return;
        }

        if (request.uri.path == _Urls.ws) {
          final type = NearbySocketType.fromRequest(request);
          if (type == NearbySocketType.message) {
            _socket = await WebSocketTransformer.upgrade(request);
            _createSocketSubscription(socketListener);
          } else {
            _fileSocketsManager.onWsRequest(request);
          }
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
          Logger.error('Got unknown request ${request.requestedUri}');
        }
      },
    );
  }

  void _createSocketSubscription(NearbyServiceMessagesListener socketListener) {
    Logger.debug('Starting socket subscription');

    if (_connectedDeviceId != null) {
      _messagesSubscription = _socket
          ?.where((e) => e != null)
          .map(MessagesStreamMapper.toMessage)
          .cast<ReceivedNearbyMessage>()
          .map((e) => MessagesStreamMapper.replaceId(e, _connectedDeviceId!))
          .listen(
        (message) async {
          try {
            _handleMessage(message);
            socketListener.onData(message);
          } catch (e) {
            Logger.error(e);
          }
          // }
        },
        onDone: () {
          state.value = CommunicationChannelState.notConnected;
          socketListener.onDone?.call();
        },
        onError: (e, s) {
          Logger.error(e);
          state.value = CommunicationChannelState.notConnected;
          socketListener.onError?.call(e, s);
        },
        cancelOnError: socketListener.cancelOnError,
      );
    }
    if (_messagesSubscription != null) {
      state.value = CommunicationChannelState.connected;
      Logger.info('Socket subscription was created successfully');
      socketListener.onCreated?.call();
    } else {
      state.value = CommunicationChannelState.notConnected;
    }
  }

  void _handleMessage(NearbyMessageBase message) {
    if (message.content is NearbyMessageFilesContent) {
      _fileSocketsManager.handleFileMessageContent(
        message.content as NearbyMessageFilesContent,
        isReceived: message is ReceivedNearbyMessage,
        sender: message is ReceivedNearbyMessage ? message.sender : null,
      );
    }
  }
}
