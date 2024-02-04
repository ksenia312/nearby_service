import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';

///
/// Nearby Service Plugin Exception.
///
/// Indicates what problem occurred in the plugin operation.
///
class NearbyServiceException implements Exception {
  NearbyServiceException(this.error) {
    Logger.error(error);
  }

  ///
  /// A call from an unsupported platform.
  ///
  factory NearbyServiceException.unsupportedPlatform({required String caller}) {
    return NearbyServiceException(
      '$caller is not supported for platform ${Platform.operatingSystem}',
    );
  }

  ///
  /// A decoding error.
  ///
  factory NearbyServiceException.unsupportedDecoding(dynamic value) {
    return NearbyServiceException(
      'Got unknown value=$value with runtimeType=${value.runtimeType}',
    );
  }

  factory NearbyServiceException.invalidMessage(
      NearbyMessageContentBase content) {
    return NearbyServiceException(
      'The message="$content" is not valid',
    );
  }

  final Object? error;

  @override
  String toString() {
    return 'NearbyServiceException{error: $error}';
  }
}
