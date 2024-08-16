import 'package:nearby_service/src/utils/constants.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

///
/// The class representing the connection information
/// of a Wi-Fi p2p group connection for Android.
///
class NearbyConnectionAndroidInfo {
  ///
  /// The class representing the Android class
  /// [WifiP2pInfo](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pInfo).
  ///
  const NearbyConnectionAndroidInfo({
    required this.ownerIpAddress,
    required this.groupFormed,
    required this.isGroupOwner,
  });

  ///
  /// Get [NearbyConnectionAndroidInfo] from [Map].
  ///
  factory NearbyConnectionAndroidInfo.fromJson(Map<String, dynamic>? json) {
    final ownerIpAddress =
        (json?['groupOwnerAddress'] ?? kNearbyUnknown) as String;
    return NearbyConnectionAndroidInfo(
      ownerIpAddress: ownerIpAddress.replaceFirst('/', ''),
      groupFormed: json?['groupFormed'] ?? false,
      isGroupOwner: json?['isGroupOwner'] ?? false,
    );
  }

  ///
  /// Group owner address.
  /// Source [WifiP2pInfo documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pInfo)
  ///
  final String ownerIpAddress;

  ///
  /// Indicates if the current device is the group owner.
  /// Source [WifiP2pInfo documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pInfo)
  ///
  final bool isGroupOwner;

  ///
  /// Indicates if a p2p group has been successfully formed.
  /// Source [WifiP2pInfo documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pInfo)
  ///
  final bool groupFormed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyConnectionAndroidInfo &&
          runtimeType == other.runtimeType &&
          ownerIpAddress == other.ownerIpAddress &&
          isGroupOwner == other.isGroupOwner &&
          groupFormed == other.groupFormed;

  @override
  int get hashCode =>
      ownerIpAddress.hashCode ^ isGroupOwner.hashCode ^ groupFormed.hashCode;

  @override
  String toString() {
    return 'NearbyConnectionAndroidInfo{ownerIpAddress: $ownerIpAddress, isGroupOwner: $isGroupOwner, groupFormed: $groupFormed}';
  }
}

/// Mapper from JSON to [NearbyConnectionAndroidInfo]
class NearbyConnectionInfoMapper {
  NearbyConnectionInfoMapper._();

  ///
  /// Converts JSON to a [NearbyConnectionAndroidInfo].
  ///
  static NearbyConnectionAndroidInfo? mapToInfo(dynamic value) {
    if (value == null) {
      return null;
    }
    final decoded = JSONDecoder.decodeMap(value);
    return NearbyConnectionAndroidInfo.fromJson(decoded);
  }
}
