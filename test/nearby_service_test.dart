import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/nearby_service_platform_interface.dart';
import 'package:nearby_service/nearby_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNearbyServicePlatform
    with MockPlatformInterfaceMixin
    implements NearbyServicePlatform {
  @override
  Stream<NearbyDevice?> getConnectedDeviceStream(device) {
    // TODO: implement getConnectedDeviceStream
    throw UnimplementedError();
  }

  @override
  Future<List<NearbyDevice>> getPeers() {
    // TODO: implement getPeers
    throw UnimplementedError();
  }

  @override
  Stream<List<NearbyDevice>> getPeersStream() {
    // TODO: implement getPeersStream
    throw UnimplementedError();
  }

  @override
  Future<String?> getPlatformModel() {
    // TODO: implement getPlatformModel
    throw UnimplementedError();
  }

  @override
  Future<String?> getPlatformVersion() {
    // TODO: implement getPlatformVersion
    throw UnimplementedError();
  }

  @override
  Future<void> openServicesSettings() {
    // TODO: implement openServicesSettings
    throw UnimplementedError();
  }

  @override
  Future<bool> disconnect(NearbyDevice device) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Stream<NearbyDevice?> getConnectedDeviceStreamById(String deviceId) {
    // TODO: implement getConnectedDeviceStreamById
    throw UnimplementedError();
  }

  @override
  Future<NearbyDeviceInfo?> getCurrentDeviceInfo() {
    // TODO: implement getCurrentDevice
    throw UnimplementedError();
  }
}

void main() {
  final NearbyServicePlatform initialPlatform = NearbyServicePlatform.instance;

  test('$MethodChannelNearbyService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNearbyService>());
  });

  test('getPlatformVersion', () async {
    NearbyService nearbyServicePlugin = NearbyService.getInstance();
    MockNearbyServicePlatform fakePlatform = MockNearbyServicePlatform();
    NearbyServicePlatform.instance = fakePlatform;

    expect(await nearbyServicePlugin.getPlatformVersion(), '42');
  });
}
