import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/constants.dart';

///
/// Wi-Fi P2P is not supported on this device
///
class NearbyServiceP2PUnsupportedException extends NearbyServiceException {
  NearbyServiceP2PUnsupportedException()
      : super(
          '${kNearbyServiceMessage}P2P_UNSUPPORTED',
        );

  @override
  String toString() {
    return 'NearbyServiceP2PUnsupportedException{error: $error}';
  }
}

///
/// The Wi-Fi P2P framework is currently busy.
/// Please wait for the current operation to complete before initiating another.
///
/// Usually this means that you have sent a request to some device and
/// now one of the peers is CONNECTING.
///
class NearbyServiceBusyException extends NearbyServiceException {
  NearbyServiceBusyException()
      : super(
          '${kNearbyServiceMessage}BUSY',
        );

  @override
  String toString() {
    return 'NearbyServiceBusyException{error: $error}';
  }
}

///
/// No service discovery requests have been made. Ensure that you have
/// initiated a service discovery request before attempting to connect.
///
class NearbyServiceNoServiceRequestsException extends NearbyServiceException {
  NearbyServiceNoServiceRequestsException()
      : super(
          '${kNearbyServiceMessage}NO_SERVICE_REQUESTS',
        );

  @override
  String toString() {
    return 'NearbyServiceNoServiceRequestsException{error: $error}';
  }
}

///
/// A generic error occurred. This could be due to various reasons such as
/// hardware issues, Wi-Fi being turned off, or temporary issues with the
/// Wi-Fi P2P framework.
///
class NearbyServiceGenericErrorException extends NearbyServiceException {
  NearbyServiceGenericErrorException()
      : super(
          '${kNearbyServiceMessage}ERROR',
        );

  @override
  String toString() {
    return 'NearbyServiceGenericErrorException{error: $error}';
  }
}

///
/// An unknown error occurred. Please check the device's Wi-Fi
/// P2P settings and ensure the device supports Wi-Fi P2P.
///
class NearbyServiceUnknownException extends NearbyServiceException {
  NearbyServiceUnknownException()
      : super(
          '${kNearbyServiceMessage}UNKNOWN',
        );

  @override
  String toString() {
    return 'NearbyServiceUnknownException{error: $error}';
  }
}
