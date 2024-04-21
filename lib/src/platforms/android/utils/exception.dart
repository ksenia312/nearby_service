import 'package:nearby_service/nearby_service.dart';

const _kNearbyServiceMessage = 'Got error from native platform with status=';

class NearbyServiceP2PUnsupportedException extends NearbyServiceException {
  NearbyServiceP2PUnsupportedException()
      : super(
          '${_kNearbyServiceMessage}P2P_UNSUPPORTED',
        );

  @override
  String toString() {
    return 'NearbyServiceP2PUnsupportedException{error: $error}';
  }
}

class NearbyServiceBusyException extends NearbyServiceException {
  NearbyServiceBusyException()
      : super(
          '${_kNearbyServiceMessage}BUSY',
        );

  @override
  String toString() {
    return 'NearbyServiceBusyException{error: $error}';
  }
}

class NearbyServiceNoServiceRequestsException extends NearbyServiceException {
  NearbyServiceNoServiceRequestsException()
      : super(
          '${_kNearbyServiceMessage}NO_SERVICE_REQUESTS',
        );

  @override
  String toString() {
    return 'NearbyServiceNoServiceRequestsException{error: $error}';
  }
}

class NearbyServiceWifiException extends NearbyServiceException {
  NearbyServiceWifiException()
      : super(
          '${_kNearbyServiceMessage}ERROR',
        );

  @override
  String toString() {
    return 'NearbyServiceWifiException{error: $error}';
  }
}

class NearbyServiceUnknownException extends NearbyServiceException {
  NearbyServiceUnknownException()
      : super(
          '${_kNearbyServiceMessage}UNKNOWN',
        );

  @override
  String toString() {
    return 'NearbyServiceUnknownException{error: $error}';
  }
}
