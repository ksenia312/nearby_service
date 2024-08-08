// ignore_for_file: constant_identifier_names
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/interface/nearby_service_exception_mapper.dart';

class NearbyServiceIOSExceptionMapper extends NearbyServiceExceptionMapper {
  @override
  bool canMap(String error) {
    return IOSFailureCodes.values.any((element) => element.name == error);
  }

  @override
  NearbyServiceException map(String error) {
    IOSFailureCodes? enumValue;
    try {
      enumValue = IOSFailureCodes.values.firstWhere(
        (element) => element.name == error,
      );
    } catch (_) {}
    return switch (enumValue) {
      IOSFailureCodes.NO_INITIALIZATION =>
        NearbyServiceNoInitializationException(),
      _ => NearbyServiceUnknownException(),
    };
  }
}

enum IOSFailureCodes { NO_INITIALIZATION }
