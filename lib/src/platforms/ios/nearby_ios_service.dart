import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/listenable.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:nearby_service/src/utils/stream_mapper.dart';

///
/// IOS implementation for [NearbyService].
///
/// Uses [NearbyServiceIOSPlatform] to perform actions.
/// Connects to the device by subscribing to messages from the selected
/// device by identifier.
///
class NearbyIOSService extends NearbyService {
  final _isBrowser = NearbyServiceListenable<bool>(initialValue: true);

  final _communicationChannelState =
      NearbyServiceListenable<CommunicationChannelState>(
    initialValue: CommunicationChannelState.notConnected,
  );

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _resourcesSubscription;

  @override
  CommunicationChannelState get communicationChannelStateValue =>
      _communicationChannelState.value;

  @override
  @Deprecated(
    'Use getCommunicationChannelStateStream or communicationChannelStateValue instead',
  )
  ValueListenable<CommunicationChannelState> get communicationChannelState =>
      _communicationChannelState.notifier;

  ///
  /// Determines whether the current device is a **Browser** or **Advertiser**.
  ///
  @Deprecated('Use getIsBrowserStream or isBrowserValue instead')
  ValueListenable<bool> get isBrowser => _isBrowser.notifier;

  ///
  /// Determines whether the current device is a **Browser** or **Advertiser**.
  ///
  bool get isBrowserValue => _isBrowser.value;

  ///
  /// Stream that determines whether the current device is a **Browser** or **Advertiser**.
  ///
  /// * Browser will only see devices with Advertiser status in the peers list.
  /// Browser sends connection requests.
  /// * Advertiser will see in the peers list only devices with Browser
  /// status that have sent it a connection request.
  /// Advertiser accepts or rejects connection requests.
  ///
  Stream<bool> getIsBrowserStream() => _isBrowser.broadcastStream;

  ///
  /// Initializes [MCNearbyServiceAdvertiser](https://developer.apple.com/documentation/multipeerconnectivity/mcnearbyserviceadvertiser)
  /// and [MCNearbyServiceBrowser](https://developer.apple.com/documentation/multipeerconnectivity/mcnearbyservicebrowser)
  /// to allow this device to be both.
  ///
  /// Creates [MCPeerID](https://developer.apple.com/documentation/multipeerconnectivity/mcpeerid) for
  /// this device.
  ///
  /// The name of the device on the network can be
  /// specified on initialization via the parameter [data].
  ///
  /// [NearbyInitializeData.iosDeviceName] will be passed to the platform as initial
  /// name. If a new name is not passed, the previous name stored
  /// in [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
  /// will be used. If there is no saved name, `UIDevice.current.name` will be used.
  ///
  @override
  Future<bool> initialize({
    NearbyInitializeData data = const NearbyInitializeData(),
  }) async {
    final result = await NearbyServiceIOSPlatform.instance.initialize(
      data.iosDeviceName,
    );

    _logResult(
      result,
      onSuccess: 'Initialized ${data.iosDeviceName}',
      onError: 'Failed to initialize ${data.iosDeviceName}',
    );
    return result;
  }

  ///
  /// Starts discovery on the local P2P network.
  ///
  /// Starts browsing for peers if [isBrowserValue] is true.
  /// Starts advertising for peers if [isBrowserValue] is false.
  ///
  @override
  Future<bool> discover() async {
    final result = _isBrowser.value
        ? await NearbyServiceIOSPlatform.instance.startBrowsing()
        : await NearbyServiceIOSPlatform.instance.startAdvertising();
    _logResult(
      result,
      onSuccess: 'Started $_currentConnectionType',
      onError: 'Failed to start $_currentConnectionType',
    );
    return result;
  }

  ///
  /// Slops discovery on the local P2P network.
  ///
  /// Slops browsing for peers if [isBrowserValue] is true.
  /// Slops advertising for peers if [isBrowserValue] is false.
  ///
  @override
  Future<bool> stopDiscovery() async {
    final result = _isBrowser.value
        ? await NearbyServiceIOSPlatform.instance.stopBrowsing()
        : await NearbyServiceIOSPlatform.instance.stopAdvertising();

    _logResult(
      result,
      onSuccess: 'Stopped $_currentConnectionType',
      onError: 'Failed to stop $_currentConnectionType',
    );
    return result;
  }

  ///
  /// Connects to the [device] on the P2P network.
  ///
  /// Invites [device] if [isBrowserValue] is true.
  /// Accepts invite from [device] if [isBrowserValue] is false.
  ///
  /// Note! Requires [NearbyIOSDevice] to be passed.
  @Deprecated('Use connectById instead')
  @override
  Future<bool> connect(NearbyDevice device) async {
    _requireIOSDevice(device);
    return connectById(device.info.id);
  }

  ///
  /// Connects to the [deviceId] on the P2P network.
  ///
  /// Invites [deviceId] if [isBrowserValue] is true.
  /// Accepts invite from [deviceId] if [isBrowserValue] is false.
  ///
  @override
  Future<bool> connectById(String deviceId) async {
    final result = _isBrowser.value
        ? await NearbyServiceIOSPlatform.instance.invite(deviceId)
        : await NearbyServiceIOSPlatform.instance.acceptInvite(deviceId);

    _logResult(
      result,
      onSuccess:
          '${_isBrowser.value ? 'Sent invitation to' : 'Accepted invitation from'} '
          '$deviceId',
      onError: 'Failed to connect to $deviceId',
    );
    return result;
  }

  ///
  /// Disconnects from the [device] on the P2P network.
  ///
  /// Note! Requires [NearbyIOSDevice] to be passed.
  ///
  @Deprecated('Use disconnectById instead')
  @override
  Future<bool> disconnect([NearbyDevice? device]) async {
    if (device == null) return false;
    _requireIOSDevice(device);
    return disconnectById(device.info.id);
  }

  ///
  /// Disconnects from the [deviceId] on the P2P network.
  ///
  @override
  Future<bool> disconnectById([String? deviceId]) async {
    if (deviceId == null) return false;
    final result = await NearbyServiceIOSPlatform.instance.disconnect(deviceId);
    _logResult(
      result,
      onSuccess: 'Disconnected from $deviceId',
      onError: 'Failed to disconnect from $deviceId',
    );
    return result;
  }

  ///
  /// Starts listening for messages from device with
  /// [NearbyCommunicationChannelData.connectedDeviceId].
  ///
  @override
  FutureOr<bool> startCommunicationChannel(
    NearbyCommunicationChannelData data,
  ) async {
    Logger.debug('Creating messages subscription');
    _communicationChannelState.add(CommunicationChannelState.loading);

    await endCommunicationChannel();
    final eventListener = data.messagesListener;
    final filesListener = data.filesListener;
    _messagesSubscription = NearbyServiceIOSPlatform.instance.messagesStream
        .where((event) => event != null)
        .map(MessagesStreamMapper.toMessage)
        .where((event) => event?.sender.id == data.connectedDeviceId)
        .cast<ReceivedNearbyMessage>()
        .listen(
      eventListener.onData,
      onDone: () {
        _communicationChannelState.add(CommunicationChannelState.notConnected);
        eventListener.onDone?.call();
      },
      onError: (e, s) {
        Logger.error(e);
        _communicationChannelState.add(CommunicationChannelState.notConnected);
        eventListener.onError?.call(e, s);
      },
      cancelOnError: eventListener.cancelOnError,
    );
    _resourcesSubscription = NearbyServiceIOSPlatform.instance.resourcesStream
        .map(ResourcesStreamMapper.toFilesPack)
        .where((event) => event != null)
        .cast<ReceivedNearbyFilesPack>()
        .listen(
      (e) => filesListener?.onData.call(e),
      onDone: filesListener?.onDone,
      onError: (e, s) {
        Logger.error(e);
        _communicationChannelState.add(CommunicationChannelState.notConnected);
        filesListener?.onError?.call(e, s);
      },
      cancelOnError: filesListener?.cancelOnError,
    );
    if (_messagesSubscription != null) {
      Logger.info('Messages subscription was created successfully');
      eventListener.onCreated?.call();
      _communicationChannelState.add(CommunicationChannelState.connected);
    } else {
      _communicationChannelState.add(CommunicationChannelState.notConnected);
    }
    if (_resourcesSubscription != null) {
      Logger.info('Resources subscription was created successfully');
    }

    return true;
  }

  ///
  /// Stops listening for messages from previously passed device with
  /// [NearbyCommunicationChannelData.connectedDeviceId].
  ///
  @override
  FutureOr<bool> endCommunicationChannel() async {
    await _messagesSubscription?.cancel();
    await _resourcesSubscription?.cancel();
    _messagesSubscription = null;
    _resourcesSubscription = null;
    _communicationChannelState.add(CommunicationChannelState.notConnected);
    Logger.debug('Communication channel was cancelled');
    return true;
  }

  ///
  /// Sends [OutgoingNearbyMessage] to [OutgoingNearbyMessage.receiver] via
  /// IOS platform.
  ///
  @override
  Future<bool> send(OutgoingNearbyMessage message) {
    if (message.isValid) {
      return NearbyServiceIOSPlatform.instance.send(message);
    }
    throw NearbyServiceException.invalidMessage(message.content);
  }

  @override
  Stream<CommunicationChannelState> getCommunicationChannelStateStream() {
    return _communicationChannelState.broadcastStream;
  }

  ///
  /// If you want to ask the user to change the name on the network,
  /// you can retrieve the name previously saved in
  /// [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) using this method.
  ///
  /// Changing the name on the network is only available for IOS,
  /// so the [NearbyIOSService] only can be used for that.
  ///
  Future<String?> getSavedDeviceName() {
    return NearbyServiceIOSPlatform.instance.getSavedDeviceName();
  }

  ///
  /// Changes the [isBrowserValue] to the passed [value].
  ///
  void setIsBrowser({required bool value}) {
    Logger.debug('Is Browser Value was set to $value');
    _isBrowser.add(value);
  }

  void _logResult(
    bool value, {
    required String onSuccess,
    required String onError,
  }) {
    if (value) {
      Logger.info(onSuccess);
    } else {
      throw NearbyServiceException(onError);
    }
  }

  String get _currentConnectionType {
    return _isBrowser.value ? 'browsing' : 'advertising';
  }

  void _requireIOSDevice(NearbyDevice device) {
    assert(
      device is NearbyIOSDevice,
      'The Nearby IOS Service can only work with the NearbyIOSDevice and not with ${device.runtimeType}',
    );
  }
}
