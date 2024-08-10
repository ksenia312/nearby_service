import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/platforms/android/utils/mapper.dart';
import 'package:nearby_service/src/platforms/ios/utils/mapper.dart';

abstract class NearbyServiceExceptionMapper {
  static NearbyServiceExceptionMapper get instance {
    if (Platform.isAndroid) {
      return NearbyServiceAndroidExceptionMapper();
    } else if (Platform.isIOS) {
      return NearbyServiceIOSExceptionMapper();
    }
    throw NearbyServiceException.unsupportedPlatform(
      caller: 'NearbyServiceExceptionMapper',
    );
  }

  bool canMap(String error);

  NearbyServiceException map(String error);
}
