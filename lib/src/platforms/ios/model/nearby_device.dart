import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

///
/// A device on a P2P network obtained from the IOS platform.
///
final class NearbyIOSDevice extends NearbyDevice {
  ///
  /// A class representing an IOS device on a P2P network.
  ///
  /// [NearbyDeviceInfo] for IOS consists of the [MCPeerID](https://developer.apple.com/documentation/multipeerconnectivity/mcpeerid) passed from the platform
  /// and a displayName passed from the platform.
  ///
  /// [MCPeerID](https://developer.apple.com/documentation/multipeerconnectivity/mcpeerid) is an identifier on the local network for IOS.
  ///
  NearbyIOSDevice({
    required super.info,
    required super.status,
    this.os,
    this.osVersion,
    this.deviceType,
  });

  ///
  /// Gets [NearbyIOSDevice] from [Map].
  ///
  factory NearbyIOSDevice.fromJson(Map<String, dynamic>? json) {
    return NearbyIOSDevice(
      info: NearbyDeviceInfo.fromJson(json),
      deviceType: json?["deviceType"],
      os: json?["os"],
      osVersion: json?["osVersion"],
      status: NearbyDeviceStatus.fromIosCode(json?['state']),
    );
  }

  ///
  /// `UIDevice.current.systemName` from IOS Platform.
  ///
  final String? os;

  ///
  /// `UIDevice.current.systemVersion` from IOS Platform.
  ///
  final String? osVersion;

  ///
  /// `UIDevice.current.model` from IOS Platform.
  ///
  final String? deviceType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NearbyIOSDevice &&
          runtimeType == other.runtimeType &&
          os == other.os &&
          osVersion == other.osVersion &&
          deviceType == other.deviceType;

  @override
  int get hashCode =>
      super.hashCode ^ os.hashCode ^ osVersion.hashCode ^ deviceType.hashCode;

  @override
  String toString() {
    return 'NearbyIOSDevice{os: $os, osVersion: $osVersion, deviceType: $deviceType}';
  }
}

///
/// Implementation of [NearbyDeviceMapper] for IOS.
///
class NearbyIOSMapper implements NearbyDeviceMapper {
  @override
  List<NearbyDevice> mapToDeviceList(dynamic value) {
    final decoded = JSONDecoder.decodeList(value);
    return [
      ...?decoded?.map(
        (e) => NearbyIOSDevice.fromJson(JSONDecoder.decodeMap(e)),
      ),
    ];
  }

  @override
  NearbyDevice? mapToDevice(dynamic value) {
    final decoded = JSONDecoder.decodeMap(value);
    if (decoded == null) return null;

    return NearbyIOSDevice.fromJson(decoded);
  }
}
