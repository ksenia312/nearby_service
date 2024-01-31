import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';

/// An implementation of [NearbyServiceIOSPlatform] that uses method channels.
class MethodChannelIOSNearbyService extends NearbyServiceIOSPlatform {
  final messageReceiver = StreamController.broadcast();

  @override
  Stream get messagesStream => messageReceiver.stream;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_service');

  @override
  Future<bool> initialize([String? deviceName]) async {
    methodChannel.setMethodCallHandler((handler) async {
      switch (handler.method) {
        case 'invoke_nearby_service_message_received':
          messageReceiver.add(handler.arguments);
          break;
      }
    });
    return (await methodChannel.invokeMethod<bool>(
          'initialize',
          deviceName != null ? {"deviceName": deviceName} : null,
        ) ??
        false);
  }

  @override
  Future<String?> getSavedDeviceName() async {
    return (await methodChannel.invokeMethod<String?>('getSavedDeviceName'));
  }

  @override
  Future<bool> startAdvertising() async {
    return (await methodChannel.invokeMethod<bool>('startAdvertising')) ??
        false;
  }

  @override
  Future<bool> startBrowsing() async {
    return (await methodChannel.invokeMethod<bool>('startBrowsing')) ?? false;
  }

  @override
  Future<bool> stopAdvertising() async {
    return (await methodChannel.invokeMethod<bool>('stopAdvertising')) ?? false;
  }

  @override
  Future<bool> stopBrowsing() async {
    return (await methodChannel.invokeMethod<bool>('stopBrowsing')) ?? false;
  }

  @override
  Future<bool> invite(String deviceId) async {
    return (await methodChannel.invokeMethod<bool?>(
          "invite",
          {"deviceId": deviceId},
        )) ??
        false;
  }

  @override
  Future<bool> acceptInvite(String deviceId) async {
    return (await methodChannel.invokeMethod<bool?>(
          "acceptInvite",
          {"deviceId": deviceId},
        )) ??
        false;
  }

  @override
  Future<bool> disconnect(String deviceId) async {
    return (await methodChannel.invokeMethod<bool?>(
          "disconnect",
          {"deviceId": deviceId},
        )) ??
        false;
  }

  @override
  Future<bool> send(OutgoingNearbyMessage message) async {
    return (await methodChannel.invokeMethod<bool?>(
          "send",
          message.toJson(),
        )) ??
        false;
  }
}
