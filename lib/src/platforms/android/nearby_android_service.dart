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

  @Deprecated(
    'Use getCommunicationChannelStateStream or communicationChannelStateValue instead',
  )
  @override
  ValueListenable<CommunicationChannelState> get communicationChannelState =>
      _socketService.communicationChannelState;

  @override
  CommunicationChannelState get communicationChannelStateValue =>
      _socketService.communicationChannelStateValue;

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
  @Deprecated('Use connectById instead')
  @override
  Future<bool> connect(NearbyDevice device) {
    _requireAndroidDevice(device);
    return NearbyServiceAndroidPlatform.instance.connect(device.info.id);
  }

  ///
  /// Connects to the [deviceId] on the Wifi Direct network.
  ///
  @override
  Future<bool> connectById(String deviceId) {
    return NearbyServiceAndroidPlatform.instance.connect(deviceId);
  }

  ///
  /// Disconnects from the [device] on the Wifi Direct network.
  ///
  /// [device] is not required for Android.
  ///
  @Deprecated('Use disconnectById instead')
  @override
  Future<bool> disconnect([NearbyDevice? device]) {
    return NearbyServiceAndroidPlatform.instance.disconnect();
  }

  ///
  /// Disconnects from the [deviceId] on the Wifi Direct network.
  ///
  /// Note! Requires [NearbyAndroidDevice] to be passed.
  ///
  @override
  Future<bool> disconnectById([String? deviceId]) {
    return NearbyServiceAndroidPlatform.instance.disconnect();
  }

  ///
  /// On [NearbyServiceBusyException] you can check for running jobs
  /// (if any of devices has [NearbyDeviceStatus.connecting]).
  ///
  /// If so, call [cancelLastConnectionProcess] to cancel last request
  ///
  Future<bool> cancelLastConnectionProcess() {
    return NearbyServiceAndroidPlatform.instance.cancelConnect();
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

  ///
  /// Streams [NearbyConnectionAndroidInfo] -
  /// information about the connection information.
  ///
  Stream<NearbyConnectionAndroidInfo?> getConnectionInfoStream() {
    return NearbyServiceAndroidPlatform.instance.getConnectionInfoStream();
  }

  @override
  Stream<CommunicationChannelState> getCommunicationChannelStateStream() {
    return _socketService.state.broadcastStream;
  }

  void _requireAndroidDevice(NearbyDevice device) {
    assert(
      device is NearbyAndroidDevice,
      'The Nearby Android Service can only work with the NearbyAndroidDevice and not with ${device.runtimeType}',
    );
  }
}
