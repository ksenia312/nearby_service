import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/unknown.dart';

///
/// The model of the device found in the P2P network.
///
abstract class NearbyDevice {
  ///
  /// The base device contains [info] and [status].
  /// These are parameters that devices will have independent of the platform.
  ///
  const NearbyDevice({required this.info, required this.status});

  ///
  /// The minimum information about the device required
  /// to display it in the list and connect to it.
  ///
  final NearbyDeviceInfo info;

  ///
  /// The connection status of the device.
  ///
  final NearbyDeviceStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyDevice &&
          runtimeType == other.runtimeType &&
          info == other.info &&
          status == other.status;

  @override
  int get hashCode => info.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'NearbyDevice{info: $info, status: $status}';
  }

  ///
  /// If you want to get different data
  /// **depending on the platform**, use [byPlatform].
  ///
  /// * The [onAndroid] callback returns this instance of [NearbyDevice],
  /// cast as [NearbyAndroidDevice] if [Platform.isAndroid] is true.
  ///
  /// * The [onIOS] callback returns this instance of [NearbyDevice],
  /// cast as [NearbyIOSDevice] if [Platform.isIOS] is true.
  ///
  /// * The [onAny] callback returns this instance of [NearbyDevice] with
  /// no casting if both [Platform.isAndroid] and [Platform.isIOS] are false.
  ///
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

///
/// Converter for devices from JSON to models.
///
abstract interface class NearbyDeviceMapper {
  ///
  /// Get the mapper instance for the current platform.
  ///
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

  ///
  /// Converts JSON to a list of [NearbyDevice].
  ///
  List<NearbyDevice> mapToDeviceList(dynamic value);

  ///
  /// Converts JSON to a [NearbyDevice].
  ///
  NearbyDevice? mapToDevice(dynamic value);
}

///
/// Minimal information about the device.
///
class NearbyDeviceInfo {
  ///
  /// Used to connect to the device via [id].
  /// Depending on the platform, [id] means different parameters.
  ///
  /// * For Android [id] is the MAC address of the device.
  /// * For IOS [id] is the [MCPeerID](https://developer.apple.com/documentation/multipeerconnectivity/mcpeerid) passed from the IOS platform.
  ///
  const NearbyDeviceInfo({
    required this.displayName,
    required this.id,
  });

  ///
  /// Get [NearbyDeviceInfo] from [Map].
  ///
  factory NearbyDeviceInfo.fromJson(Map<String, dynamic>? json) {
    return NearbyDeviceInfo(
      displayName: json?['displayName'] ?? kNearbyUnknown,
      id: json?['id'],
    );
  }

  ///
  /// The name of the device in the context of a P2P network.
  ///
  final String displayName;

  ///
  /// Depending on the platform, [id] means different parameters.
  ///
  /// * For Android [id] is the MAC address of the device.
  /// * For IOS [id] is the [MCPeerID](https://developer.apple.com/documentation/multipeerconnectivity/mcpeerid) passed from the IOS platform.
  ///
  final String id;

  ///
  /// Get [Map] from [NearbyDeviceInfo].
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }
}
