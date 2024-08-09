import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/interface/nearby_service_exception_mapper.dart';

class ResultHandler {
  ResultHandler._();

  static ResultHandler instance = ResultHandler._();

  T handle<T>(dynamic result) {
    if (result is String &&
        NearbyServiceExceptionMapper.instance.canMap(result)) {
      throw NearbyServiceExceptionMapper.instance.map(result);
    }
    if (result is T) {
      return result;
    }

    throw NearbyServiceException(
      'Got unknown value from native platform: $result',
    );
  }
}
