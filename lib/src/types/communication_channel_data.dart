import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

///
/// A class for creating a communication channel.
///
class NearbyCommunicationChannelData {
  ///
  /// Contains [connectedDeviceId] of the device to be connected
  /// to and additional data.
  ///
  /// Since Android connection is more customizable,
  /// additional data [androidData] is created for it.
  ///
  const NearbyCommunicationChannelData(
    this.connectedDeviceId, {
    required this.messagesListener,
    this.filesListener,
    this.androidData = const NearbyAndroidCommunicationChannelData(),
  });

  ///
  /// Identifier of the device to be connected to.
  ///
  final String connectedDeviceId;

  ///
  /// Listener for message stream changes.
  ///
  final NearbyServiceMessagesListener messagesListener;

  ///
  /// Listener for message stream changes.
  ///
  final NearbyServiceFilesListener? filesListener;

  ///
  /// Android-specific connection data.
  ///
  final NearbyAndroidCommunicationChannelData androidData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyCommunicationChannelData &&
          runtimeType == other.runtimeType &&
          connectedDeviceId == other.connectedDeviceId &&
          messagesListener == other.messagesListener &&
          androidData == other.androidData;

  @override
  int get hashCode =>
      connectedDeviceId.hashCode ^
      messagesListener.hashCode ^
      androidData.hashCode;

  @override
  String toString() {
    return 'NearbyCommunicationChannelData{connectedDeviceId: $connectedDeviceId, eventListener: $messagesListener, androidData: $androidData}';
  }
}

///
/// Android-specific connection data.
///
class NearbyAndroidCommunicationChannelData {
  ///
  /// By default, no data needs to be passed, all values are already set.
  /// This class is used to customize connection of server to client or client to server.
  ///
  const NearbyAndroidCommunicationChannelData({
    this.clientReconnectInterval = const Duration(seconds: 5),
    this.serverListener,
    this.port = 4045,
  });

  ///
  /// The interval at which the client will ping the server
  /// while waiting for it to be created.
  ///
  final Duration clientReconnectInterval;

  ///
  /// Listener of events that come to the server.
  ///
  final ValueChanged<HttpRequest>? serverListener;

  ///
  /// The port on which the socket will be created.
  ///
  final int port;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyAndroidCommunicationChannelData &&
          runtimeType == other.runtimeType &&
          clientReconnectInterval == other.clientReconnectInterval &&
          serverListener == other.serverListener &&
          port == other.port;

  @override
  int get hashCode =>
      clientReconnectInterval.hashCode ^
      serverListener.hashCode ^
      port.hashCode;

  @override
  String toString() {
    return 'NearbyAndroidCommunicationChannelData{clientReconnectInterval: $clientReconnectInterval, serverListener: $serverListener, port: $port}';
  }
}
