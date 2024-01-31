import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/nearby_service_platform_interface.dart';
import 'package:nearby_service/src/utils/logger.dart';

export 'package:nearby_service/src/platforms/android/android.dart';
export 'package:nearby_service/src/platforms/ios/ios.dart';
export 'src/models/models.dart';
export 'src/utils/utils.dart';
export 'src/types/types.dart';

abstract class NearbyService {
  static NearbyService getInstance({NearbyServiceLogLevel? logLevel}) {
    if (logLevel != null) {
      Logger.level = logLevel;
    }

    if (Platform.isAndroid) {
      Logger.debug('Created Nearby Android Service');
      return NearbyAndroidService();
    } else if (Platform.isIOS) {
      Logger.debug('Created Nearby IOS Service');
      return NearbyIOSService();
    } else {
      throw NearbyServiceException.unsupportedPlatform(
        caller: 'getInstance()',
      );
    }
  }

  late final NearbyIOSService? ios = get(
    onIOS: (e) => e,
  );
  late final NearbyAndroidService? android = get(
    onAndroid: (e) => e,
  );

  ValueListenable<bool> get isCommunicationChannelConnecting;

  Future<String?> getPlatformVersion() {
    return NearbyServicePlatform.instance.getPlatformVersion();
  }

  Future<String?> getPlatformModel() {
    return NearbyServicePlatform.instance.getPlatformModel();
  }

  Future<NearbyDevice?> getCurrentDevice() {
    return NearbyServicePlatform.instance.getCurrentDevice();
  }

  Future<void> openServicesSettings() {
    return NearbyServicePlatform.instance.openServicesSettings();
  }

  Future<List<NearbyDevice>> getPeers() {
    return NearbyServicePlatform.instance.getPeers();
  }

  Stream<List<NearbyDevice>> getPeersStream() {
    return NearbyServicePlatform.instance.getPeersStream();
  }

  Stream<NearbyDevice?> getConnectedDeviceStream(NearbyDevice device) {
    return NearbyServicePlatform.instance.getConnectedDeviceStream(device);
  }

  Future<bool> initialize({
    NearbyInitializeData data = const NearbyInitializeData(),
  });

  Future<bool> discover();

  Future<bool> stopDiscovery();

  Future<bool> connect(NearbyDevice device);

  Future<bool> disconnect(NearbyDevice device);

  FutureOr<bool> startCommunicationChannel(
    NearbyCommunicationChannelData data,
  );

  FutureOr<bool> endCommunicationChannel();

  FutureOr<bool> send(OutgoingNearbyMessage message);
}

extension NearbyServiceGetterExtension on NearbyService {
  T? get<T>({
    T Function(NearbyAndroidService)? onAndroid,
    T Function(NearbyIOSService)? onIOS,
    T Function(NearbyService)? onAny,
  }) {
    assert(
      onAndroid != null || onIOS != null || onAny != null,
      'You should provide at least one of (onAndroid, onIOS, onAny)',
    );
    if (this is NearbyAndroidService && onAndroid != null) {
      return onAndroid(this as NearbyAndroidService);
    }
    if (this is NearbyIOSService && onIOS != null) {
      return onIOS(this as NearbyIOSService);
    }
    if (onAny != null) {
      return onAny(this);
    }
    return null;
  }
}
