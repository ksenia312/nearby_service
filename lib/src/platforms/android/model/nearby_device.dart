import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/constants.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

///
/// A device on a P2P network obtained from the Android platform.
///
final class NearbyAndroidDevice extends NearbyDevice {
  ///
  /// The class representing the Android class
  /// [WifiP2pDevice](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice).
  ///
  /// Automatically generates the [info] field from the [deviceName]
  /// and [deviceAddress] fields.
  ///
  /// They are used because in a Wifi Direct environment
  /// the MAC address of the device is an identifier on the network.
  ///
  NearbyAndroidDevice({
    required String deviceName,
    required this.deviceAddress,
    this.isGroupOwner = false,
    this.isServiceDiscoveryCapable = false,
    this.primaryDeviceType = kNearbyUnknown,
    this.wpsKeypadSupported = false,
    this.wpsPbcSupported = false,
    this.wpsDisplaySupported = false,
    this.secondaryDeviceType,
    super.status = NearbyDeviceStatus.unavailable,
  }) : super(
          info: NearbyDeviceInfo(
            displayName: deviceName,
            id: deviceAddress,
          ),
        );

  ///
  /// Gets [NearbyAndroidDevice] from [Map]
  ///
  factory NearbyAndroidDevice.fromJson(Map<String, dynamic>? json) {
    return NearbyAndroidDevice(
      deviceName: json?['deviceName'] ?? kNearbyUnknown,
      deviceAddress: json?['deviceAddress'] ?? kNearbyUnknown,
      isGroupOwner: json?['isGroupOwner'] ?? false,
      isServiceDiscoveryCapable: json?['isServiceDiscoveryCapable'] ?? false,
      primaryDeviceType: json?['primaryDeviceType'] ?? kNearbyUnknown,
      secondaryDeviceType: json?['secondaryDeviceType'],
      wpsDisplaySupported: json?['wpsDisplaySupported'] ?? false,
      wpsKeypadSupported: json?['wpsKeypadSupported'] ?? false,
      wpsPbcSupported: json?['wpsPbcSupported'] ?? false,
      status: NearbyDeviceStatus.fromAndroidCode(json?['status']),
    );
  }

  ///
  /// The device MAC address uniquely identifies a Wi-Fi p2p device.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final String deviceAddress;

  ///
  /// True if the device is a group owner.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final bool isGroupOwner;

  ///
  /// True if the device is capable of service discovery.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final bool isServiceDiscoveryCapable;

  ///
  /// Primary device type identifies the type of device.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final String primaryDeviceType;

  ///
  /// Secondary device type is an optional attribute.
  /// that can be provided by a device in addition to the primary device type.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final String? secondaryDeviceType;

  ///
  /// True if WPS keypad configuration is supported.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final bool wpsKeypadSupported;

  ///
  /// True if WPS push button configuration is supported.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final bool wpsPbcSupported;

  ///
  /// True if WPS display configuration is supported.
  /// Source [WifiP2pDevice documentation](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice)
  ///
  final bool wpsDisplaySupported;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NearbyAndroidDevice &&
          runtimeType == other.runtimeType &&
          deviceAddress == other.deviceAddress &&
          isGroupOwner == other.isGroupOwner &&
          isServiceDiscoveryCapable == other.isServiceDiscoveryCapable &&
          primaryDeviceType == other.primaryDeviceType &&
          secondaryDeviceType == other.secondaryDeviceType &&
          wpsKeypadSupported == other.wpsKeypadSupported &&
          wpsPbcSupported == other.wpsPbcSupported &&
          wpsDisplaySupported == other.wpsDisplaySupported;

  @override
  int get hashCode =>
      super.hashCode ^
      deviceAddress.hashCode ^
      isGroupOwner.hashCode ^
      isServiceDiscoveryCapable.hashCode ^
      primaryDeviceType.hashCode ^
      secondaryDeviceType.hashCode ^
      wpsKeypadSupported.hashCode ^
      wpsPbcSupported.hashCode ^
      wpsDisplaySupported.hashCode;

  @override
  String toString() {
    return 'NearbyAndroidDevice{deviceAddress: $deviceAddress, isGroupOwner: $isGroupOwner, isServiceDiscoveryCapable: $isServiceDiscoveryCapable, primaryDeviceType: $primaryDeviceType, secondaryDeviceType: $secondaryDeviceType, wpsKeypadSupported: $wpsKeypadSupported, wpsPbcSupported: $wpsPbcSupported, wpsDisplaySupported: $wpsDisplaySupported}';
  }
}

///
/// Implementation of [NearbyDeviceMapper] for Android.
///
class NearbyAndroidMapper implements NearbyDeviceMapper {
  @override
  List<NearbyDevice> mapToDeviceList(dynamic value) {
    final decoded = JSONDecoder.decodeList(value);
    return [
      ...?decoded?.map(
        (e) => NearbyAndroidDevice.fromJson(JSONDecoder.decodeMap(e)),
      ),
    ];
  }

  @override
  NearbyDevice? mapToDevice(dynamic value) {
    final decoded = JSONDecoder.decodeMap(value);
    if (decoded == null) return null;

    return NearbyAndroidDevice.fromJson(decoded);
  }
}
