enum NearbyDeviceStatus {
  available,
  connected,
  failed,
  connecting,
  unavailable;

  bool get isConnected => this == NearbyDeviceStatus.connected;

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
