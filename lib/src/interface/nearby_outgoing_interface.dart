import 'package:nearby_service/nearby_service.dart';

abstract interface class NearbyOutgoingInterface {
  NearbyOutgoingInterface({required this.receiver});

  ///
  /// Data of the user to whom the message is addressed.
  ///
  final NearbyDeviceInfo receiver;
}
