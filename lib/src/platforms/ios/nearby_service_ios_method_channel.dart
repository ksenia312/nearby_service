import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/result_handler.dart';

/// An implementation of [NearbyServiceIOSPlatform] that uses method channels.
class MethodChannelIOSNearbyService extends NearbyServiceIOSPlatform {
  final messageReceiver = StreamController.broadcast();
  final resourcesReceiver = StreamController.broadcast();

  @override
  Stream get messagesStream => messageReceiver.stream;

  @override
  Stream get resourcesStream => resourcesReceiver.stream;

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
        case 'invoke_nearby_service_resources_received':
          resourcesReceiver.add(handler.arguments);
          break;
      }
    });
    final result = await methodChannel.invokeMethod(
      'initialize',
      deviceName != null ? {"deviceName": deviceName} : null,
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<String?> getSavedDeviceName() async {
    final result = await methodChannel.invokeMethod<String?>(
      'getSavedDeviceName',
    );
    return ResultHandler.instance.handle(result);
  }

  @override
  Future<bool> startAdvertising() async {
    final result = await methodChannel.invokeMethod('startAdvertising');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> startBrowsing() async {
    final result = await methodChannel.invokeMethod('startBrowsing');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> stopAdvertising() async {
    final result = await methodChannel.invokeMethod('stopAdvertising');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> stopBrowsing() async {
    final result = await methodChannel.invokeMethod('stopBrowsing');
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> invite(String deviceId) async {
    final result = await methodChannel.invokeMethod(
      "invite",
      {"deviceId": deviceId},
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> acceptInvite(String deviceId) async {
    final result = await methodChannel.invokeMethod(
      "acceptInvite",
      {"deviceId": deviceId},
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> disconnect(String deviceId) async {
    final result = await methodChannel.invokeMethod(
      "disconnect",
      {"deviceId": deviceId},
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }

  @override
  Future<bool> send(OutgoingNearbyMessage message) async {
    final result = await methodChannel.invokeMethod(
      "send",
      message.toJson(),
    );
    return ResultHandler.instance.handle<bool?>(result) ?? false;
  }
}
