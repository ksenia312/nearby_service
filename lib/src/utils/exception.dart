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
  factory NearbyServiceException.unsupportedPlatform({
    required String caller,
  }) =>
      NearbyServiceUnsupportedPlatformException(caller: caller);

  ///
  /// A decoding error.
  ///
  factory NearbyServiceException.unsupportedDecoding(dynamic value) =>
      NearbyServiceUnsupportedDecodingException(value);

  ///
  /// Invalid message error
  ///
  factory NearbyServiceException.invalidMessage(NearbyMessageContent content) =>
      NearbyServiceInvalidMessageException(content);

  final Object? error;

  @override
  String toString() {
    return 'NearbyServiceException{error: $error}';
  }
}

///
/// A call from an unsupported platform.
///
class NearbyServiceUnsupportedPlatformException extends NearbyServiceException {
  ///
  /// A call from an unsupported platform - default constructor
  ///
  NearbyServiceUnsupportedPlatformException({required String caller})
      : super(
          '$caller is not supported for platform ${Platform.operatingSystem}',
        );

  @override
  String toString() {
    return 'NearbyServiceUnsupportedPlatformException{error: $error}';
  }
}

///
/// A decoding error
///
class NearbyServiceUnsupportedDecodingException extends NearbyServiceException {
  ///
  /// A decoding error - default constructor
  ///
  NearbyServiceUnsupportedDecodingException(dynamic value)
      : super(
          'Got unknown value=$value with runtimeType=${value.runtimeType}',
        );

  @override
  String toString() {
    return 'NearbyServiceUnsupportedDecodingException{error: $error}';
  }
}

///
/// Invalid message error
///
class NearbyServiceInvalidMessageException extends NearbyServiceException {
  ///
  /// Invalid message error - default constructor
  ///
  NearbyServiceInvalidMessageException(NearbyMessageContent content)
      : super(
          'The message="$content" is not valid',
        );

  @override
  String toString() {
    return 'NearbyServiceInvalidMessageException{error: $error}';
  }
}
