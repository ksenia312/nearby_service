import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/constants.dart';
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
  /// Usage of the plugin on an unsupported platform
  ///
  factory NearbyServiceException.unsupportedPlatform({
    required String caller,
  }) =>
      NearbyServiceUnsupportedPlatformException(caller: caller);

  ///
  /// Error decoding messages from native platform to Dart (open an issue if
  /// this happens!)
  ///
  factory NearbyServiceException.unsupportedDecoding(dynamic value) =>
      NearbyServiceUnsupportedDecodingException(value);

  ///
  /// An attempt to send an invalid message on the sender's side. Add content
  /// validation to your messages
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
/// Usage of the plugin on an unsupported platform
///
class NearbyServiceUnsupportedPlatformException extends NearbyServiceException {
  ///
  /// Usage of the plugin on an unsupported platform - default constructor
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
/// Error decoding messages from native platform to Dart (open an issue if
/// this happens!)
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
/// An attempt to send an invalid message on the sender's side. Add content
/// validation to your messages
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

///
/// Error when the plugin is not initialized. Please call initialize() method first.
///
class NearbyServiceNoInitializationException extends NearbyServiceException {
  NearbyServiceNoInitializationException()
      : super(
          '${kNearbyServiceMessage}NO_INITIALIZATION',
        );

  @override
  String toString() {
    return 'NearbyServiceNoInitializationException{error: $error}';
  }
}
