import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:nearby_service/src/utils/result_handler.dart';

/// An implementation of [NearbyServiceAndroidPlatform] that uses method channels.
class MethodChannelAndroidNearbyService extends NearbyServiceAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_service');

  @override
  Future<bool> initialize() async {
    final result = await methodChannel.invokeMethod(
      'initialize',
      {"logLevel": Logger.level.name},
    );

    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    final result = await methodChannel.invokeMethod('requestPermissions');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> checkWifiService() async {
    final result = await methodChannel.invokeMethod('checkWifiService');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<NearbyConnectionAndroidInfo?> getConnectionInfo() async {
    final result = ResultHandler.instance.handle(
      await methodChannel.invokeMethod('getConnectionInfo'),
    );
    return NearbyConnectionInfoMapper.mapToInfo(result);
  }

  @override
  Future<bool> discover() async {
    final result = await methodChannel.invokeMethod('discover');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> stopDiscovery() async {
    final result = await methodChannel.invokeMethod('stopDiscovery');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> connect(String deviceAddress) async {
    final result = await methodChannel.invokeMethod(
      "connect",
      {"deviceAddress": deviceAddress},
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod("disconnect");
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> cancelConnect() async {
    final result = await methodChannel.invokeMethod("cancelConnect");
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Stream<NearbyConnectionAndroidInfo?> getConnectionInfoStream() {
    const connectedDeviceChannel = EventChannel(
      "nearby_service_connection_info",
    );
    return connectedDeviceChannel.receiveBroadcastStream().map(
          (e) => ResultHandler.instance.handle(
            NearbyConnectionInfoMapper.mapToInfo(e),
          ),
        );
  }
}
