import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:nearby_service/src/utils/stream_mapper.dart';

part 'ping_manager.dart';

part 'network.dart';

class NearbySocketService {
  NearbySocketService(this._manager);

  final NearbyAndroidService _manager;
  final _pingManager = NearbySocketPingManager();
  final _network = NearbyServiceNetwork();

  final isConnecting = ValueNotifier(false);
  NearbyConnectionAndroidInfo? connectionInfo;

  String? _connectedDeviceId;
  WebSocket? _socket;
  StreamSubscription<ReceivedNearbyMessage>? _messagesSubscription;

  Future<bool> startSocket({
    required NearbyCommunicationChannelData data,
  }) async {
    isConnecting.value = true;
    _connectedDeviceId = data.connectedDeviceId;
    connectionInfo = await _manager.getConnectionInfo();
    if (connectionInfo != null && connectionInfo!.groupFormed) {
      final androidData = data.androidData;
      if (connectionInfo!.isGroupOwner) {
        await _startServerSubscription(
          serverListener: androidData.serverListener,
          socketListener: data.eventListener,
          info: connectionInfo!,
          port: androidData.port,
        );
        return true;
      } else {
        await _tryConnectClient(
          socketListener: data.eventListener,
          reconnectInterval: androidData.clientReconnectInterval,
          info: connectionInfo!,
          port: androidData.port,
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> send(OutgoingNearbyMessage message) async {
    if (_socket != null && message.receiver.id == _connectedDeviceId) {
      final sender = await _manager.getCurrentDevice();
      if (sender != null) {
        _socket!.add(
          jsonEncode(
            {
              'message': message.value,
              'sender': sender.info.toJson(),
            },
          ),
        );
      }
      return true;
    }
    return false;
  }

  Future<bool> cancel() async {
    try {
      isConnecting.value = false;
      await _messagesSubscription?.cancel();
      _messagesSubscription = null;
      _socket = null;
      _connectedDeviceId = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _tryConnectClient({
    required NearbyServiceStreamListener socketListener,
    required NearbyConnectionAndroidInfo info,
    required int port,
    required Duration reconnectInterval,
  }) async {
    final response = await _network.pingServer(
      address: info.ownerIpAddress,
      port: port,
    );

    if (await _pingManager.checkPong(response)) {
      _socket = await _network.connectToSocket(
        ownerIpAddress: info.ownerIpAddress,
        port: port,
      );
      _createSocketSubscription(socketListener);
    } else {
      Logger.debug(
        'Retry to connect to the server in ${reconnectInterval.inSeconds}s',
      );
      Future.delayed(reconnectInterval, () {
        _tryConnectClient(
          socketListener: socketListener,
          reconnectInterval: reconnectInterval,
          info: info,
          port: port,
        );
      });
    }
  }

  Future<void> _startServerSubscription({
    required NearbyServiceStreamListener socketListener,
    required NearbyConnectionAndroidInfo info,
    required int port,
    ValueChanged<HttpRequest>? serverListener,
  }) async {
    final httpServer = await _network.startServer(
      ownerIpAddress: info.ownerIpAddress,
      port: port,
    );
    httpServer?.listen(
      (request) async {
        serverListener?.call(request);
        final isPing = await _pingManager.checkPing(request);
        if (isPing) {
          Logger.debug('Server got ping request');
          _network.pongClient(request);
          return;
        }

        if (request.uri.path == '/ws') {
          _socket = await WebSocketTransformer.upgrade(request);
          _createSocketSubscription(socketListener);
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
          Logger.error('Got unknown request ${request.requestedUri}');
        }
      },
    );
  }

  void _createSocketSubscription(NearbyServiceStreamListener socketListener) {
    Logger.debug('Starting socket subscription');
    isConnecting.value = false;
    if (_connectedDeviceId != null) {
      _messagesSubscription = _socket
          ?.map(MessagesStreamMapper.toMessage)
          .where((event) => event != null)
          .cast<ReceivedNearbyMessage>()
          .map((e) => MessagesStreamMapper.replaceId(e, _connectedDeviceId!))
          .listen(
        socketListener.onData,
        onDone: socketListener.onDone,
        onError: (e, s) {
          Logger.error(e);
          socketListener.onError?.call(e, s);
        },
        cancelOnError: socketListener.cancelOnError,
      );
    }
    if (_messagesSubscription != null) {
      Logger.info('Socket subscription was created successfully');
      socketListener.onCreated?.call(_messagesSubscription!);
    }
  }
}
