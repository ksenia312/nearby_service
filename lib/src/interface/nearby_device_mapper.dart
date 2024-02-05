import 'dart:io';

import 'package:nearby_service/nearby_service.dart';

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
