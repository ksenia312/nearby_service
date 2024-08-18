import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';

import 'nearby_service_platform_interface.dart';
import 'src/utils/result_handler.dart';

/// An implementation of [NearbyServicePlatform] that uses method channels.
class MethodChannelNearbyService extends NearbyServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_service');

  @override
  Future<String?> getPlatformVersion() async {
    final result = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return ResultHandler.instance.handle<String?>(result);
  }

  @override
  Future<String?> getPlatformModel() async {
    final result = await methodChannel.invokeMethod<String>('getPlatformModel');
    return ResultHandler.instance.handle<String?>(result);
  }

  @override
  Future<NearbyDeviceInfo?> getCurrentDeviceInfo() async {
    final result = await methodChannel.invokeMethod('getCurrentDevice');
    final updatedResult = ResultHandler.instance.handle(result);
    return NearbyDeviceMapper.instance.mapToDevice(updatedResult)?.info;
  }

  @override
  Future<void> openServicesSettings() async {
    await methodChannel.invokeMethod<bool>('openServicesSettings');
  }

  @override
  Future<List<NearbyDevice>> getPeers() async {
    final result = await methodChannel.invokeMethod('getPeers');
    final updatedResult = ResultHandler.instance.handle(result);
    return NearbyDeviceMapper.instance.mapToDeviceList(updatedResult);
  }

  @override
  Stream<List<NearbyDevice>> getPeersStream() {
    const peersChannel = EventChannel("nearby_service_peers");
    return peersChannel.receiveBroadcastStream().map((e) {
      final updatedResult = ResultHandler.instance.handle(e);
      return NearbyDeviceMapper.instance.mapToDeviceList(updatedResult);
    });
  }

  @override
  @Deprecated('Use getConnectedDeviceStreamById instead')
  Stream<NearbyDevice?> getConnectedDeviceStream(NearbyDevice device) {
    return getConnectedDeviceStreamById(device.info.id);
  }

  @override
  Stream<NearbyDevice?> getConnectedDeviceStreamById(String deviceId) {
    const connectedDeviceChannel = EventChannel(
      "nearby_service_connected_device",
    );
    return connectedDeviceChannel.receiveBroadcastStream(deviceId).map((e) {
      final updatedResult = ResultHandler.instance.handle(e);
      return NearbyDeviceMapper.instance.mapToDevice(updatedResult);
    });
  }
}
