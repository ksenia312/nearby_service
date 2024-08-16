import 'package:nearby_service/nearby_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nearby_service_method_channel.dart';

abstract class NearbyServicePlatform extends PlatformInterface {
  NearbyServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static NearbyServicePlatform _instance = MethodChannelNearbyService();

  /// The default instance of [NearbyServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelNearbyService].
  static NearbyServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NearbyServicePlatform] when
  /// they register themselves.
  static set instance(NearbyServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getPlatformModel() {
    throw UnimplementedError('getPlatformModel() has not been implemented.');
  }

  Future<NearbyDeviceInfo?> getCurrentDeviceInfo() {
    throw UnimplementedError('getCurrentDevice() has not been implemented.');
  }

  Future<void> openServicesSettings() {
    throw UnimplementedError(
        'openServicesSettings() has not been implemented.');
  }

  Future<List<NearbyDevice>> getPeers() {
    throw UnimplementedError('getPeers() has not been implemented.');
  }

  Stream<List<NearbyDevice>> getPeersStream() {
    throw UnimplementedError('streamPeers() has not been implemented.');
  }

  @Deprecated('Use getConnectedDeviceStreamById instead')
  Stream<NearbyDevice?> getConnectedDeviceStream(NearbyDevice device) {
    throw UnimplementedError(
        'getConnectedDeviceStream() has not been implemented.');
  }

  Stream<NearbyDevice?> getConnectedDeviceStreamById(String deviceId) {
    throw UnimplementedError(
      'getConnectedDeviceStreamById() has not been implemented.',
    );
  }

  @Deprecated(
    'This method will be removed. Method disconnect is platform-specific and you should use NearbyServiceIOSPlatform.disconnectById or NearbyServiceAndroidPlatform.disconnectById instead.',
  )
  Future<bool> disconnect(NearbyDevice device) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }
}
