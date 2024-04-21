import 'package:nearby_service/nearby_service.dart';

class NearbyServiceAndroidExceptionMapper {
  NearbyServiceAndroidExceptionMapper._();

  static NearbyServiceException map(String error) {
    AndroidFailureCodes? enumValue;
    try {
      enumValue = AndroidFailureCodes.values.firstWhere(
        (element) => element.name == error,
      );
    } catch (_) {}
    return switch (enumValue) {
      AndroidFailureCodes.BUSY => NearbyServiceBusyException(),
      AndroidFailureCodes.ERROR => NearbyServiceGenericErrorException(),
      AndroidFailureCodes.P2P_UNSUPPORTED =>
        NearbyServiceP2PUnsupportedException(),
      AndroidFailureCodes.NO_SERVICE_REQUESTS =>
        NearbyServiceNoServiceRequestsException(),
      _ => NearbyServiceUnknownException(),
    };
  }
}

// ignore: constant_identifier_names
enum AndroidFailureCodes { P2P_UNSUPPORTED, BUSY, NO_SERVICE_REQUESTS, ERROR }
