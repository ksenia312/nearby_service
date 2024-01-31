import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/decoder.dart';

class NearbyAndroidDevice extends NearbyDevice {
  NearbyAndroidDevice({
    required String deviceName,
    required super.status,
    required this.deviceAddress,
    required this.isGroupOwner,
    required this.isServiceDiscoveryCapable,
    required this.primaryDeviceType,
    required this.wpsKeypadSupported,
    required this.wpsPbcSupported,
    required this.wpsDisplaySupported,
    this.secondaryDeviceType,
  }) : super(
          info: NearbyDeviceInfo(
            displayName: deviceName,
            id: deviceAddress,
          ),
        );

  factory NearbyAndroidDevice.fromJson(Map<String, dynamic>? json) {
    return NearbyAndroidDevice(
      deviceName: json?['deviceName'] ?? NearbyDevice.unknown,
      deviceAddress: json?['deviceAddress'] ?? NearbyDevice.unknown,
      isGroupOwner: json?['isGroupOwner'] ?? false,
      isServiceDiscoveryCapable: json?['isServiceDiscoveryCapable'] ?? false,
      primaryDeviceType: json?['primaryDeviceType'] ?? NearbyDevice.unknown,
      secondaryDeviceType: json?['secondaryDeviceType'],
      wpsDisplaySupported: json?['wpsDisplaySupported'] ?? false,
      wpsKeypadSupported: json?['wpsKeypadSupported'] ?? false,
      wpsPbcSupported: json?['wpsPbcSupported'] ?? false,
      status: NearbyDeviceStatus.fromAndroidCode(json?['status']),
    );
  }

  final String deviceAddress;
  final bool isGroupOwner;
  final bool isServiceDiscoveryCapable;
  final String primaryDeviceType;
  final String? secondaryDeviceType;
  final bool wpsKeypadSupported;
  final bool wpsPbcSupported;
  final bool wpsDisplaySupported;
}

class NearbyAndroidMapper implements NearbyDeviceMapper {
  @override
  List<NearbyDevice> mapToDeviceList(dynamic value) {
    final decoded = Decoder.decodeList(value);
    return [
      ...?decoded?.map(
        (e) => NearbyAndroidDevice.fromJson(e as Map<String, dynamic>?),
      ),
    ];
  }

  @override
  NearbyDevice? mapToDevice(dynamic value) {
    return NearbyAndroidDevice.fromJson(Decoder.decodeMap(value));
  }
}
