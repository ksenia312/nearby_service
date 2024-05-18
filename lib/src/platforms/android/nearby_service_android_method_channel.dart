import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';

import 'utils/mapper.dart';

/// An implementation of [NearbyServiceAndroidPlatform] that uses method channels.
class MethodChannelAndroidNearbyService extends NearbyServiceAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_service');

  @override
  Future<bool> initialize() async {
    return (await methodChannel.invokeMethod<bool>(
          'initialize',
          {"logLevel": Logger.level.name},
        )) ??
        false;
  }

  @override
  Future<bool> requestPermissions() async {
    return (await methodChannel.invokeMethod<bool>('requestPermissions')) ??
        false;
  }

  @override
  Future<bool> checkWifiService() async {
    return (await methodChannel.invokeMethod<bool>('checkWifiService')) ??
        false;
  }

  @override
  Future<NearbyConnectionAndroidInfo?> getConnectionInfo() async {
    return NearbyConnectionInfoMapper.mapToInfo(
      await methodChannel.invokeMethod('getConnectionInfo'),
    );
  }

  @override
  Future<bool> discover() async {
    final result = await methodChannel.invokeMethod('discover');
    return _handleBooleanResult(result);
  }

  @override
  Future<bool> stopDiscovery() async {
    final result = await methodChannel.invokeMethod('stopDiscovery');
    return _handleBooleanResult(result);
  }

  @override
  Future<bool> connect(String deviceAddress) async {
    final result = await methodChannel.invokeMethod(
      "connect",
      {"deviceAddress": deviceAddress},
    );
    return _handleBooleanResult(result);
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod("disconnect");
    return _handleBooleanResult(result);
  }

  @override
  Future<bool> cancelConnect() async {
    print('call cancelConnect');
    final result = await methodChannel.invokeMethod("cancelConnect");
    return _handleBooleanResult(result);
  }

  @override
  Stream<NearbyConnectionAndroidInfo?> getConnectionInfoStream() {
    const connectedDeviceChannel = EventChannel(
      "nearby_service_connection_info",
    );
    return connectedDeviceChannel.receiveBroadcastStream().map(
          (e) => NearbyConnectionInfoMapper.mapToInfo(e),
        );
  }

  bool _handleBooleanResult(dynamic result) {
    if (result is bool) {
      return result;
    } else if (result is String) {
      throw NearbyServiceAndroidExceptionMapper.map(result);
    } else {
      throw NearbyServiceException(
        'Got unknown value from native platform: $result',
      );
    }
  }
}
