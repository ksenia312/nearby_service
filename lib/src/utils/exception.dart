import 'dart:io';

import 'package:nearby_service/src/utils/logger.dart';

class NearbyServiceException implements Exception {
  NearbyServiceException(this.error) {
    Logger.error(error);
  }

  factory NearbyServiceException.unsupportedPlatform({required String caller}) {
    return NearbyServiceException(
      '$caller is not supported for platform ${Platform.operatingSystem}',
    );
  }

  factory NearbyServiceException.unsupportedDecoding(dynamic value) {
    return NearbyServiceException(
      'Got unknown value=$value with runtimeType=${value.runtimeType}',
    );
  }

  final Object? error;
}
