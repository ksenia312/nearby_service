import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

class NearbyCommunicationChannelData<T> {
  const NearbyCommunicationChannelData(
    this.connectedDeviceId, {
    required this.eventListener,
    this.androidData = const NearbyAndroidCommunicationChannelData(),
  });

  final String connectedDeviceId;
  final NearbyServiceStreamListener<ReceivedNearbyMessage> eventListener;
  final NearbyAndroidCommunicationChannelData androidData;
}

class NearbyAndroidCommunicationChannelData {
  const NearbyAndroidCommunicationChannelData({
    this.clientReconnectInterval = const Duration(seconds: 5),
    this.serverListener,
    this.port = 4045,
  });

  final Duration clientReconnectInterval;
  final ValueChanged<HttpRequest>? serverListener;
  final int port;
}
