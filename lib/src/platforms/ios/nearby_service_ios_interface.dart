import 'dart:async';

import 'package:nearby_service/nearby_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nearby_service_ios_method_channel.dart';

abstract class NearbyServiceIOSPlatform extends PlatformInterface {
  NearbyServiceIOSPlatform() : super(token: _token);

  static final Object _token = Object();

  static NearbyServiceIOSPlatform _instance = MethodChannelIOSNearbyService();

  /// The default instance of [NearbyServiceIOSPlatform] to use.
  static NearbyServiceIOSPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NearbyServiceIOSPlatform] when
  /// they register themselves.
  static set instance(NearbyServiceIOSPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream get messagesStream {
    throw UnimplementedError('messagesStream() has not been implemented.');
  }

  Stream get resourcesStream {
    throw UnimplementedError('resourcesStream() has not been implemented.');
  }

  Future<bool> initialize([String? deviceName]) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<String?> getSavedDeviceName() {
    throw UnimplementedError('getSavedDeviceName() has not been implemented.');
  }

  Future<bool> startBrowsing() {
    throw UnimplementedError('startBrowsing() has not been implemented.');
  }

  Future<bool> startAdvertising() {
    throw UnimplementedError('startAdvertising() has not been implemented.');
  }

  Future<bool> stopBrowsing() {
    throw UnimplementedError('stopBrowsing() has not been implemented.');
  }

  Future<bool> stopAdvertising() {
    throw UnimplementedError('stopAdvertising() has not been implemented.');
  }

  Future<bool> invite(String deviceId) {
    throw UnimplementedError('invite() has not been implemented.');
  }

  Future<bool> acceptInvite(String deviceId) {
    throw UnimplementedError('acceptInvite() has not been implemented.');
  }

  Future<bool> disconnect(String deviceId) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<bool> send(OutgoingNearbyMessage message) {
    throw UnimplementedError('send() has not been implemented.');
  }
}
