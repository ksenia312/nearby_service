import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
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
  final _isBrowser = ValueNotifier<bool>(true);
  final _state = ValueNotifier(CommunicationChannelState.notConnected);

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _resourcesSubscription;

  @override
  ValueListenable<CommunicationChannelState> get communicationChannelState =>
      _state;

  ///
  /// Determines whether the current device is a **Browser** or **Advertiser**.
  ///
  /// * Browser will only see devices with Advertiser status in the peers list.
  /// Browser sends connection requests.
  /// * Advertiser will see in the peers list only devices with Browser
  /// status that have sent it a connection request.
  /// Advertiser accepts or rejects connection requests.
  ///
  ValueListenable<bool> get isBrowser => _isBrowser;

  String get _currentConnectionType {
    return _isBrowser.value ? 'browsing' : 'advertising';
  }

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
  /// Starts browsing for peers if [isBrowser] is true.
  /// Starts advertising for peers if [isBrowser] is false.
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
  /// Slops browsing for peers if [isBrowser] is true.
  /// Slops advertising for peers if [isBrowser] is false.
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
  /// Invites [device] if [isBrowser] is true.
  /// Accepts invite from [device] if [isBrowser] is false.
  ///
  /// Note! Requires [NearbyIOSDevice] to be passed.
  ///
  @override
  Future<bool> connect(NearbyDevice device) async {
    _requireIOSDevice(device);
    final result = _isBrowser.value
        ? await NearbyServiceIOSPlatform.instance.invite(device.info.id)
        : await NearbyServiceIOSPlatform.instance.acceptInvite(device.info.id);

    _logResult(
      result,
      onSuccess:
          '${_isBrowser.value ? 'Sent invitation to' : 'Accepted invitation from'} '
          '${device.info.id}',
      onError: 'Failed to connect to ${device.info.id}',
    );
    return result;
  }

  ///
  /// Disconnects from the [device] on the P2P network.
  ///
  /// Note! Requires [NearbyIOSDevice] to be passed.
  ///
  @override
  Future<bool> disconnect(NearbyDevice device) async {
    _requireIOSDevice(device);
    final result = await NearbyServiceIOSPlatform.instance.disconnect(
      device.info.id,
    );
    _logResult(
      result,
      onSuccess: 'Disconnected from ${device.info.id}',
      onError: 'Failed to disconnect from ${device.info.id}',
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
    _state.value = CommunicationChannelState.loading;
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
        _state.value = CommunicationChannelState.notConnected;
        eventListener.onDone?.call();
      },
      onError: (e, s) {
        Logger.error(e);
        _state.value = CommunicationChannelState.notConnected;
        eventListener.onError?.call(e, s);
      },
      cancelOnError: eventListener.cancelOnError,
    );
    _resourcesSubscription = NearbyServiceIOSPlatform.instance.resourcesStream
        .map(ResourcesStreamMapper.toFiles)
        .where((event) => event != null)
        .cast<List<NearbyFile>>()
        .listen(
      (e) => filesListener?.onData.call(e),
      onDone: filesListener?.onDone,
      onError: (e, s) {
        Logger.error(e);
        _state.value = CommunicationChannelState.notConnected;
        filesListener?.onError?.call(e, s);
      },
      cancelOnError: filesListener?.cancelOnError,
    );
    if (_messagesSubscription != null) {
      Logger.info('Messages subscription was created successfully');
      eventListener.onCreated?.call();
      _state.value = CommunicationChannelState.connected;
    } else {
      _state.value = CommunicationChannelState.notConnected;
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
    _state.value = CommunicationChannelState.notConnected;
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
  /// Changes the [isBrowser] to the passed [value].
  ///
  void setIsBrowser({required bool value}) {
    Logger.debug('Is Browser Value was set to $value');
    _isBrowser.value = value;
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

  void _requireIOSDevice(NearbyDevice device) {
    assert(
      device is NearbyIOSDevice,
      'The Nearby IOS Service can only work with the NearbyIOSDevice and not with ${device.runtimeType}',
    );
  }
}
