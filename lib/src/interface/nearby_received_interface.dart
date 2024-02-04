import 'package:nearby_service/nearby_service.dart';

abstract interface class NearbyReceivedInterface {
  NearbyReceivedInterface({required this.sender});

  ///
  /// Data of the user from whom the message came.
  ///
  final NearbyDeviceInfo sender;
}
