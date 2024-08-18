import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/nearby_service_platform_interface.dart';
import 'package:nearby_service/src/utils/logger.dart';

export 'package:nearby_service/src/platforms/android/android.dart';
export 'package:nearby_service/src/platforms/ios/ios.dart';
export 'src/model/model.dart';
export 'src/utils/utils.dart';
export 'src/types/types.dart';
export 'src/base/base.dart';
export 'src/interface/interface.dart';

///
/// The main tool for working with a P2P network.
/// Implementations:
/// * for Android - [NearbyAndroidService]
/// * for IOS - [NearbyIOSService]
///
/// **The plugin is not supported for other platforms yet**
///
abstract class NearbyService {
  ///
  /// The only way to get an instance of [NearbyService].
  ///
  /// Creates a service suitable for the current platform.
  /// Otherwise it throws [NearbyServiceException].
  ///
  static NearbyService getInstance({NearbyServiceLogLevel? logLevel}) {
    if (logLevel != null) {
      Logger.level = logLevel;
    }

    if (Platform.isAndroid) {
      Logger.debug('Created Nearby Android Service');
      return NearbyAndroidService();
    } else if (Platform.isIOS) {
      Logger.debug('Created Nearby IOS Service');
      return NearbyIOSService();
    } else {
      throw NearbyServiceException.unsupportedPlatform(
        caller: 'getInstance()',
      );
    }
  }

  ///
  /// Returns [NearbyService] cast as [NearbyIOSService] if the current
  /// platform is IOS. Otherwise, returns null.
  ///
  late final NearbyIOSService? ios = get(
    onIOS: (e) => e,
  );

  ///
  /// Returns [NearbyService] cast as [NearbyAndroidService] if the current
  /// platform is Android. Otherwise, returns null.
  ///
  late final NearbyAndroidService? android = get(
    onAndroid: (e) => e,
  );

  ///
  /// **A value to determine the communication channel's status.**
  ///
  /// For **Android** this is the socket connection state.
  /// The server can wait for the client to connect,
  /// and the client can be waiting for the server to be created.
  /// Also, both can be in connected and unconnected states.
  ///
  /// For **IOS** this is the state of the message stream subscription.
  /// which is generated for the device with the current connected device ID.
  ///
  @Deprecated(
    'Use getCommunicationChannelStateStream or communicationChannelStateValue instead',
  )
  ValueListenable<CommunicationChannelState> get communicationChannelState;

  ///
  /// **A value to determine the communication channel's status.**
  ///
  /// For **Android** this is the socket connection state.
  /// The server can wait for the client to connect,
  /// and the client can be waiting for the server to be created.
  /// Also, both can be in connected and unconnected states.
  ///
  /// For **IOS** this is the state of the message stream subscription.
  /// which is generated for the device with the current connected device ID.
  ///
  /// **Can be used to retrieve the current state of the communication channel without listening to the stream via** [getCommunicationChannelStateStream].
  ///
  CommunicationChannelState get communicationChannelStateValue;

  ///
  /// Gets version of current platform.
  ///
  /// * Sample answer for Android: "Android 14"
  /// * Sample answer for iOS: "IOS 17.2"
  ///
  Future<String?> getPlatformVersion() {
    return NearbyServicePlatform.instance.getPlatformVersion();
  }

  ///
  /// Gets model of current device.
  ///
  /// * Sample answer for Android: "Android"
  /// * Sample answer for iOS: "IPhone 15 Pro"
  ///
  Future<String?> getPlatformModel() {
    return NearbyServicePlatform.instance.getPlatformModel();
  }

  ///
  /// Getting info about the current device in P2P scope.
  ///
  /// This method can be used to define the name
  /// of the current device to be displayed on the network to other users.
  ///
  /// Also [NearbyDeviceInfo] contains the connection ID. Note that
  /// the ID obtained from [getCurrentDeviceInfo] for Android
  /// will always be **02:00:00:00:00:00** for privacy issues.
  /// For iOS, it can be safely used.
  ///
  Future<NearbyDeviceInfo?> getCurrentDeviceInfo() {
    return NearbyServicePlatform.instance.getCurrentDeviceInfo();
  }

  ///
  /// Since Wi-fi must be enabled to use the plugin in Android,
  /// [openServicesSettings] can be used to redirect the user to the **Wi-fi**
  /// service settings on Android.
  ///
  /// For iOS it is not necessary to have Wi-fi enabled.
  /// In case of its absence, the platform will try to establish a connection
  /// by other methods. However, this method will open the settings page
  /// for iOS, if you want the user to use Wi-fi.
  ///
  Future<void> openServicesSettings() {
    return NearbyServicePlatform.instance.openServicesSettings();
  }

  ///
  /// A single retrieval of the current list of devices in a P2P network.
  ///
  /// Returns the list of [NearbyDevice] that have been stored so far.
  /// If you want to use a constantly updated list of devices, use [getPeersStream].
  ///
  Future<List<NearbyDevice>> getPeers() {
    return NearbyServicePlatform.instance.getPeers();
  }

  ///
  /// Returns a constantly updating list of [NearbyDevice] that
  /// the platform-specific service has found at each point in time.
  ///
  Stream<List<NearbyDevice>> getPeersStream() {
    return NearbyServicePlatform.instance.getPeersStream();
  }

  ///
  /// Returns the  constantly updating [NearbyDevice] you are currently connected to.
  /// If it returns null, then there is no connection at the moment.
  ///
  @Deprecated('Use getConnectedDeviceStreamById instead')
  Stream<NearbyDevice?> getConnectedDeviceStream(NearbyDevice device) {
    return NearbyServicePlatform.instance.getConnectedDeviceStream(device);
  }

  ///
  /// Returns the  constantly updating [NearbyDevice] you are currently connected to.
  /// If it returns null, then there is no connection at the moment.
  ///
  Stream<NearbyDevice?> getConnectedDeviceStreamById(String deviceId) {
    return NearbyServicePlatform.instance
        .getConnectedDeviceStreamById(deviceId);
  }

  ///
  /// Initialization of a platform-specific service.
  ///
  /// The [initialize] method must be called before calling any
  /// other getters and methods related to P2P network (all except
  /// [getPlatformVersion] and [getPlatformModel]).
  ///
  Future<bool> initialize({
    NearbyInitializeData data = const NearbyInitializeData(),
  });

  ///
  /// Starts searching for devices using a platform-specific service.
  ///
  /// Note that the [NearbyIOSService] implementation starts **browsing** or
  /// **advertising** depending on the [NearbyIOSService.isBrowserValue].
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  Future<bool> discover();

  ///
  /// Stops searching for devices using a platform-specific service.
  ///
  /// Note that the [NearbyIOSService] implementation stops **browsing** or
  /// **advertising** depending on the [NearbyIOSService.isBrowserValue].
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  Future<bool> stopDiscovery();

  ///
  /// Connects to passed [device] using a platform-specific service.
  ///
  /// Note that the [NearbyIOSService] implementation **invites** or
  /// **accepts invite** depending on the [NearbyIOSService.isBrowser].
  ///
  /// Note that if [Platform.isIOS] == true, [NearbyIOSDevice] should be passed.
  /// If [Platform.isAndroid] == true, [NearbyAndroidDevice] should be passed.
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  @Deprecated('Use connectById instead')
  Future<bool> connect(NearbyDevice device);

  ///
  /// Connects to passed [deviceId] using a platform-specific service.
  ///
  /// Note that the [NearbyIOSService] implementation **invites** or
  /// **accepts invite** depending on the [NearbyIOSService.isBrowserValue].
  ///
  /// Note that if [Platform.isIOS] == true, [NearbyIOSDevice] should be passed.
  /// If [Platform.isAndroid] == true, [NearbyAndroidDevice] should be passed.
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  Future<bool> connectById(String deviceId);

  ///
  /// Disconnects from passed [device] using a platform-specific service.
  ///
  /// Note that if [Platform.isIOS] == true, [NearbyIOSDevice] should be passed.
  /// If [Platform.isAndroid] == true, [NearbyAndroidDevice] should be passed.
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  /// **For IOS [device] is required!!!**
  @Deprecated('Use disconnectById instead')
  Future<bool> disconnect([NearbyDevice? device]);

  ///
  /// Disconnects from passed [deviceId] using a platform-specific service.
  ///
  /// Note that if [Platform.isIOS] == true, [NearbyIOSDevice] should be passed.
  /// If [Platform.isAndroid] == true, [NearbyAndroidDevice] should be passed.
  ///
  /// On Android can throw mapped from native platform exceptions:
  /// 1. [NearbyServiceBusyException]
  /// 2. [NearbyServiceP2PUnsupportedException]
  /// 3. [NearbyServiceNoServiceRequestsException]
  /// 4. [NearbyServiceGenericErrorException]
  /// 5. [NearbyServiceUnknownException]
  ///
  /// **For IOS [deviceId] is required!!!**
  Future<bool> disconnectById([String? deviceId]);

  ///
  /// If the device is already connected, it does not mean that you can
  /// send and receive data.
  ///
  /// There is a separate function for this in [NearbyService] - communication channel.
  /// You need to call [startCommunicationChannel] before using [send].
  /// A communication channel can only be created if you are connected to some device.
  ///
  /// You can monitor changes in communication channel state using the [getCommunicationChannelStateStream] method.
  ///
  FutureOr<bool> startCommunicationChannel(NearbyCommunicationChannelData data);

  ///
  /// If you called [startCommunicationChannel], remember that you have
  /// created a subscription to receive messages.
  ///
  /// Accordingly, it is essential to terminate any subscription.
  /// Use [endCommunicationChannel] for this purpose.
  ///
  FutureOr<bool> endCommunicationChannel();

  ///
  /// **A stream with values of [CommunicationChannelState] to determine the communication channel's status.**
  ///
  /// For **Android** this is the socket connection state.
  /// The server can wait for the client to connect,
  /// and the client can be waiting for the server to be created.
  /// Also, both can be in connected and unconnected states.
  ///
  /// For **IOS** this is the state of the message stream subscription.
  /// which is generated for the device with the current connected device ID.
  ///
  Stream<CommunicationChannelState> getCommunicationChannelStateStream();

  ///
  /// Method to send data to the created communication channel.
  ///
  FutureOr<bool> send(OutgoingNearbyMessage message);
}

extension NearbyServiceGetterExtension on NearbyService {
  ///
  /// If you want to do different actions or get different data
  /// **depending on the platform**, use [get].
  ///
  /// * The [onAndroid] callback returns this instance of [NearbyService],
  /// cast as [NearbyAndroidService] if [Platform.isAndroid] is true.
  ///
  /// * The [onIOS] callback returns this instance of [NearbyService],
  /// cast as [NearbyIOSService] if [Platform.isIOS] is true.
  ///
  /// * The [onAny] callback returns this instance of [NearbyService] with
  /// no casting if both [Platform.isAndroid] and [Platform.isIOS] are false.
  ///
  /// **Note: any of the callbacks must not be null!**
  ///
  T? get<T>({
    T Function(NearbyAndroidService)? onAndroid,
    T Function(NearbyIOSService)? onIOS,
    T Function(NearbyService)? onAny,
  }) {
    assert(
      onAndroid != null || onIOS != null || onAny != null,
      'You should provide at least one of (onAndroid, onIOS, onAny)',
    );
    if (this is NearbyAndroidService && onAndroid != null) {
      return onAndroid(this as NearbyAndroidService);
    }
    if (this is NearbyIOSService && onIOS != null) {
      return onIOS(this as NearbyIOSService);
    }
    if (onAny != null) {
      return onAny(this);
    }
    return null;
  }
}
