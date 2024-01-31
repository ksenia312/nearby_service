///
/// Data for plugin initialization.
///
class NearbyInitializeData {
  ///
  /// By default, it does not require any data.
  ///
  /// There is an option to pass the device name to IOS [iosDeviceName].
  /// For Android platform changing device name in P2P network is not supported.
  ///
  const NearbyInitializeData({this.iosDeviceName});

  ///
  /// The device name for IOS on the P2P network.
  ///
  final String? iosDeviceName;
}
