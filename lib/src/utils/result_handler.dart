import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/platforms/android/utils/mapper.dart';

class ResultHandler {
  ResultHandler._();

  static ResultHandler instance = ResultHandler._();

  T handle<T>(dynamic result) {
    if (NearbyServiceAndroidExceptionMapper.canMap(result)) {
      throw NearbyServiceAndroidExceptionMapper.map(result);
    }
    if (result is T) {
      return result;
    }

    throw NearbyServiceException(
      'Got unknown value from native platform: $result',
    );
  }
}
