import 'dart:io';

import 'package:nearby_service/nearby_service.dart';

///
/// The model of the device found in the P2P network.
///
abstract base class NearbyDevice {
  ///
  /// The base device contains [info] and [status].
  /// These are parameters that devices will have independent of the platform.
  ///
  const NearbyDevice({required this.info, required this.status});

  ///
  /// The minimum information about the device required
  /// to display it in the list and connect to it.
  ///
  final NearbyDeviceInfo info;

  ///
  /// The connection status of the device.
  ///
  final NearbyDeviceStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyDevice &&
          runtimeType == other.runtimeType &&
          info == other.info &&
          status == other.status;

  @override
  int get hashCode => info.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'NearbyDevice{info: $info, status: $status}';
  }

  ///
  /// If you want to get different data
  /// **depending on the platform**, use [byPlatform].
  ///
  /// * The [onAndroid] callback returns this instance of [NearbyDevice],
  /// cast as [NearbyAndroidDevice] if [Platform.isAndroid] is true.
  ///
  /// * The [onDarwin] callback returns this instance of [NearbyDevice],
  /// cast as [NearbyDarwinDevice] if [Platform.isIOS] or [Platform.isMacOS] is true.
  ///
  /// * The [onAny] callback returns this instance of [NearbyDevice] with
  /// no casting if both [Platform.isAndroid] and [Platform.isIOS] or [Platform.isMacOS] are false.
  ///
  T? byPlatform<T>({
    T Function(NearbyDevice)? onAny,
    T Function(NearbyAndroidDevice)? onAndroid,
    T Function(NearbyDarwinDevice)? onDarwin,
  }) {
    if (this is NearbyDarwinDevice && onDarwin != null) {
      return onDarwin(this as NearbyDarwinDevice);
    } else if (this is NearbyAndroidDevice && onAndroid != null) {
      return onAndroid(this as NearbyAndroidDevice);
    } else {
      return onAny?.call(this);
    }
  }
}
