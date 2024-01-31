import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

import 'socket_service/nearby_socket_service.dart';

class NearbyAndroidService extends NearbyService {
  late final _socketService = NearbySocketService(this);

  @override
  ValueListenable<bool> get isCommunicationChannelConnecting {
    return _socketService.isConnecting;
  }

  NearbyConnectionAndroidInfo? get connectionInfo {
    return _socketService.connectionInfo;
  }

  @override
  Future<bool> initialize({
    NearbyInitializeData data = const NearbyInitializeData(),
  }) {
    return NearbyServiceAndroidPlatform.instance.initialize();
  }

  @override
  Future<bool> discover() {
    return NearbyServiceAndroidPlatform.instance.discover();
  }

  @override
  Future<bool> stopDiscovery() {
    return NearbyServiceAndroidPlatform.instance.stopDiscovery();
  }

  @override
  Future<bool> connect(NearbyDevice device) {
    _requireAndroidDevice(device);
    return NearbyServiceAndroidPlatform.instance.connect(device.info.id);
  }

  @override
  Future<bool> disconnect(NearbyDevice device) {
    _requireAndroidDevice(device);
    return NearbyServiceAndroidPlatform.instance.disconnect(device.info.id);
  }

  Future<bool> requestPermissions() {
    return NearbyServiceAndroidPlatform.instance.requestPermissions();
  }

  Future<bool> checkWifiService() {
    return NearbyServiceAndroidPlatform.instance.checkWifiService();
  }

  Future<NearbyConnectionAndroidInfo?> getConnectionInfo() {
    return NearbyServiceAndroidPlatform.instance.getConnectionInfo();
  }

  @override
  FutureOr<bool> startCommunicationChannel(
    NearbyCommunicationChannelData data,
  ) {
    return _socketService.startSocket(data: data);
  }

  @override
  FutureOr<bool> endCommunicationChannel() {
    return _socketService.cancel();
  }

  @override
  FutureOr<bool> send(OutgoingNearbyMessage message) {
    return _socketService.send(message);
  }

  void _requireAndroidDevice(NearbyDevice device) {
    assert(
      device is NearbyAndroidDevice,
      'The Nearby Android Service can only work with the NearbyAndroidDevice and not with ${device.runtimeType}',
    );
  }
}
