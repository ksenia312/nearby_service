import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

import 'socket_service/nearby_socket_service.dart';

///
/// Android implementation for [NearbyService].
///
/// Uses [NearbyServiceAndroidPlatform] to perform actions.
/// Connects to the device via a socket from [NearbySocketService].
///
class NearbyAndroidService extends NearbyService {
  late final _socketService = NearbySocketService(this);

  @override
  ValueListenable<CommunicationChannelState> get communicationChannelState {
    return _socketService.state;
  }

  ///
  /// Initializes Android [WifiP2PManager](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pManager)
  ///
  /// Starts listening for changes to the P2P network.
  /// Adds platform-level action listeners.
  ///
  @override
  Future<bool> initialize({
    NearbyInitializeData data = const NearbyInitializeData(),
  }) {
    return NearbyServiceAndroidPlatform.instance.initialize();
  }

  ///
  /// Starts discovery of the Wifi Direct network.
  ///
  @override
  Future<bool> discover() {
    return NearbyServiceAndroidPlatform.instance.discover();
  }

  ///
  /// Stops discovery of the Wifi Direct network.
  ///
  @override
  Future<bool> stopDiscovery() {
    return NearbyServiceAndroidPlatform.instance.stopDiscovery();
  }

  ///
  /// Connects to the [device] on the Wifi Direct network.
  ///
  /// Note! Requires [NearbyAndroidDevice] to be passed.
  ///
  @override
  Future<bool> connect(NearbyDevice device) {
    _requireAndroidDevice(device);
    return NearbyServiceAndroidPlatform.instance.connect(device.info.id);
  }

  ///
  /// Disconnects from the [device] on the Wifi Direct network.
  ///
  /// Note! Requires [NearbyAndroidDevice] to be passed.
  ///
  @override
  Future<bool> disconnect(NearbyDevice device) {
    _requireAndroidDevice(device);
    return NearbyServiceAndroidPlatform.instance.disconnect(device.info.id);
  }

  ///
  /// Starts a socket service to transfer data. Uses device with
  /// [NearbyCommunicationChannelData.connectedDeviceId].
  ///
  @override
  FutureOr<bool> startCommunicationChannel(
    NearbyCommunicationChannelData data,
  ) {
    return _socketService.startSocket(data: data);
  }

  ///
  /// Ends the socket service to stop transferring data.
  ///
  @override
  FutureOr<bool> endCommunicationChannel() {
    return _socketService.cancel();
  }

  ///
  /// Adds [OutgoingNearbyMessage] to the socket.
  ///
  @override
  FutureOr<bool> send(OutgoingNearbyMessage message) {
    return _socketService.send(message);
  }

  ///
  /// Request permissions at the platform level.
  /// **This is required for Android for using the plugin!**
  ///
  /// For Android APIs less 33 requests `ACCESS_FINE_LOCATION` permission.
  ///
  /// For Android APIs equal to 33 or more, requests `ACCESS_FINE_LOCATION`
  /// and `NEARBY_WIFI_DEVICES` permissions.
  ///
  Future<bool> requestPermissions() {
    return NearbyServiceAndroidPlatform.instance.requestPermissions();
  }

  ///
  /// Checks if Wi-fi is enabled.
  /// **Wi-fi must be enabled for Android to use the plugin!**
  ///
  Future<bool> checkWifiService() {
    return NearbyServiceAndroidPlatform.instance.checkWifiService();
  }

  ///
  /// Returns [NearbyConnectionAndroidInfo] -
  /// information about the connection information.
  ///
  Future<NearbyConnectionAndroidInfo?> getConnectionInfo() {
    return NearbyServiceAndroidPlatform.instance.getConnectionInfo();
  }

  void _requireAndroidDevice(NearbyDevice device) {
    assert(
      device is NearbyAndroidDevice,
      'The Nearby Android Service can only work with the NearbyAndroidDevice and not with ${device.runtimeType}',
    );
  }
}
