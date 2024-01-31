import 'dart:io';

import 'package:nearby_service/nearby_service.dart';

abstract class NearbyDevice {
  static const unknown = 'unknown';

  const NearbyDevice({required this.info, required this.status});

  final NearbyDeviceInfo info;
  final NearbyDeviceStatus status;

  T? byPlatform<T>({
    T Function(NearbyDevice)? onAny,
    T Function(NearbyAndroidDevice)? onAndroid,
    T Function(NearbyIOSDevice)? onIOS,
  }) {
    if (this is NearbyIOSDevice && onIOS != null) {
      return onIOS(this as NearbyIOSDevice);
    } else if (this is NearbyAndroidDevice && onAndroid != null) {
      return onAndroid(this as NearbyAndroidDevice);
    } else {
      return onAny?.call(this);
    }
  }
}

abstract interface class NearbyDeviceMapper {
  static NearbyDeviceMapper get instance {
    if (Platform.isAndroid) {
      return NearbyAndroidMapper();
    }
    if (Platform.isIOS) {
      return NearbyIOSMapper();
    }

    throw NearbyServiceException.unsupportedPlatform(
      caller: 'NearbyDeviceMapper',
    );
  }

  List<NearbyDevice> mapToDeviceList(dynamic value);

  NearbyDevice? mapToDevice(dynamic value);
}

class NearbyDeviceInfo {
  const NearbyDeviceInfo({
    required this.displayName,
    required this.id,
  });

  factory NearbyDeviceInfo.fromJson(Map<String, dynamic>? json) {
    return NearbyDeviceInfo(
      displayName: json?['displayName'] ?? NearbyDevice.unknown,
      id: json?['id'] ?? NearbyDevice.unknown,
    );
  }

  final String displayName;
  final String id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }
}
