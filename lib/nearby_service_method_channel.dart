import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';

import 'nearby_service_platform_interface.dart';

/// An implementation of [NearbyServicePlatform] that uses method channels.
class MethodChannelNearbyService extends NearbyServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_service');

  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<String?> getPlatformModel() {
    return methodChannel.invokeMethod<String>('getPlatformModel');
  }

  @override
  Future<NearbyDeviceInfo?> getCurrentDeviceInfo() async {
    return NearbyDeviceMapper.instance
        .mapToDevice(
          await methodChannel.invokeMethod('getCurrentDevice'),
        )
        ?.info;
  }

  @override
  Future<void> openServicesSettings() async {
    await methodChannel.invokeMethod<bool>('openServicesSettings');
  }

  @override
  Future<List<NearbyDeviceBase>> getPeers() async {
    return NearbyDeviceMapper.instance.mapToDeviceList(
      await methodChannel.invokeMethod('fetchPeers'),
    );
  }

  @override
  Stream<List<NearbyDeviceBase>> getPeersStream() {
    const peersChannel = EventChannel("nearby_service_peers");
    return peersChannel.receiveBroadcastStream().map((e) {
      return NearbyDeviceMapper.instance.mapToDeviceList(e);
    });
  }

  @override
  Stream<NearbyDeviceBase?> getConnectedDeviceStream(NearbyDeviceBase device) {
    const connectedDeviceChannel = EventChannel(
      "nearby_service_connected_device",
    );
    return connectedDeviceChannel.receiveBroadcastStream(device.info.id).map(
          (e) => NearbyDeviceMapper.instance.mapToDevice(e),
        );
  }
}
