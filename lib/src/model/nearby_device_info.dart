import 'package:nearby_service/src/utils/constants.dart';

///
/// Minimal information about the device.
///
final class NearbyDeviceInfo {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyDeviceInfo &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          id == other.id;

  @override
  int get hashCode => displayName.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'NearbyDeviceInfo{displayName: $displayName, id: $id}';
  }
}
