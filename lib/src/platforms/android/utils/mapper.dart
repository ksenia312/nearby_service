// ignore_for_file: constant_identifier_names
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/interface/nearby_service_exception_mapper.dart';

class NearbyServiceAndroidExceptionMapper extends NearbyServiceExceptionMapper {
  @override
  bool canMap(String error) {
    return AndroidFailureCodes.values.any((element) => element.name == error);
  }

  @override
  NearbyServiceException map(String error) {
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
      AndroidFailureCodes.NO_INITIALIZATION =>
        NearbyServiceNoInitializationException(),
      _ => NearbyServiceUnknownException(),
    };
  }
}

enum AndroidFailureCodes {
  P2P_UNSUPPORTED,
  BUSY,
  NO_SERVICE_REQUESTS,
  ERROR,
  NO_INITIALIZATION,
}
