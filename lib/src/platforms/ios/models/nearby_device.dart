import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/decoder.dart';

class NearbyIOSDevice extends NearbyDevice {
  NearbyIOSDevice({
    required super.info,
    required super.status,
    this.os,
    this.osVersion,
    this.deviceType,
  });

  factory NearbyIOSDevice.fromJson(Map<String, dynamic>? json) {
    return NearbyIOSDevice(
      info: NearbyDeviceInfo.fromJson(json),
      deviceType: json?["deviceType"],
      os: json?["os"],
      osVersion: json?["osVersion"],
      status: NearbyDeviceStatus.fromIosCode(json?['state']),
    );
  }

  final String? os;
  final String? osVersion;
  final String? deviceType;
}

class NearbyIOSMapper implements NearbyDeviceMapper {
  @override
  List<NearbyDevice> mapToDeviceList(dynamic value) {
    final decoded = Decoder.decodeList(value);
    return [
      ...?decoded?.map(
        (e) => NearbyIOSDevice.fromJson(e as Map<String, dynamic>?),
      ),
    ];
  }

  @override
  NearbyDevice? mapToDevice(dynamic value) {
    return NearbyIOSDevice.fromJson(
      Decoder.decodeMap(value),
    );
  }
}
