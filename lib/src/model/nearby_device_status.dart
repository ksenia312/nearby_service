///
/// Status of device connection.
///
enum NearbyDeviceStatus {
  available,
  connected,
  failed,
  connecting,
  unavailable;

  ///
  /// Checks if status is [NearbyDeviceStatus.connected]
  ///
  bool get isConnected => this == NearbyDeviceStatus.connected;

  ///
  /// Checks if status is [NearbyDeviceStatus.available]
  ///
  bool get isAvailable => this == NearbyDeviceStatus.available;

  ///
  /// Checks if status is [NearbyDeviceStatus.failed]
  ///
  bool get isFailed => this == NearbyDeviceStatus.failed;

  ///
  /// Checks if status is [NearbyDeviceStatus.connecting]
  ///
  bool get isConnecting => this == NearbyDeviceStatus.connecting;

  ///
  /// Checks if status is [NearbyDeviceStatus.unavailable]
  ///
  bool get isUnavailable => this == NearbyDeviceStatus.unavailable;

  ///
  /// Get [NearbyDeviceStatus] from the Android platform code.
  ///
  /// You can read about it on the [Android developer site](https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice#constants_1).
  ///
  static NearbyDeviceStatus fromAndroidCode(num? code) {
    if (code == null) {
      return NearbyDeviceStatus.failed;
    }
    return switch (code) {
      (0) => NearbyDeviceStatus.connected,
      (1) => NearbyDeviceStatus.connecting,
      (2) => NearbyDeviceStatus.failed,
      (3) => NearbyDeviceStatus.available,
      (4) => NearbyDeviceStatus.unavailable,
      (_) => NearbyDeviceStatus.failed,
    };
  }

  ///
  /// Get [NearbyDeviceStatus] from the IOS platform code.
  ///
  /// You can read about it on the [IOS developer site](https://developer.apple.com/documentation/multipeerconnectivity/mcsessionstate).
  ///
  static NearbyDeviceStatus fromIosCode(String? code) {
    if (code == null) {
      return NearbyDeviceStatus.failed;
    }
    final value = num.tryParse(code);
    return switch (value) {
      (0) => NearbyDeviceStatus.available,
      (1) => NearbyDeviceStatus.connecting,
      (2) => NearbyDeviceStatus.connected,
      (_) => NearbyDeviceStatus.failed,
    };
  }
}
