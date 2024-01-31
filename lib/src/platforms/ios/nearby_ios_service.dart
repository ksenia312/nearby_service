import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';
import 'package:nearby_service/src/utils/stream_mapper.dart';

class NearbyIOSService extends NearbyService {
  final _isBrowser = ValueNotifier<bool>(true);
  final _isCommunicationChannelConnecting = ValueNotifier<bool>(false);

  StreamSubscription<ReceivedNearbyMessage>? _messagesSubscription;

  @override
  ValueListenable<bool> get isCommunicationChannelConnecting =>
      _isCommunicationChannelConnecting;

  ValueListenable<bool> get isBrowser => _isBrowser;

  String get _currentConnectionType {
    return _isBrowser.value ? 'browsing' : 'advertising';
  }

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

  @override
  FutureOr<bool> startCommunicationChannel(
    NearbyCommunicationChannelData data,
  ) async {
    Logger.debug('Creating messages subscription');
    _isCommunicationChannelConnecting.value = true;
    await endCommunicationChannel();
    final eventListener = data.eventListener;
    _messagesSubscription = NearbyServiceIOSPlatform.instance.messagesStream
        .map(MessagesStreamMapper.toMessage)
        .where((event) => event?.sender.id == data.connectedDeviceId)
        .where((event) => event != null)
        .cast<ReceivedNearbyMessage>()
        .listen(
      eventListener.onData,
      onDone: eventListener.onDone,
      onError: (e, s) {
        Logger.error(e);
        eventListener.onError?.call(e, s);
      },
      cancelOnError: eventListener.cancelOnError,
    );
    if (_messagesSubscription != null) {
      Logger.info('Messages subscription was created successfully');
      eventListener.onCreated?.call(_messagesSubscription!);
    }
    _isCommunicationChannelConnecting.value = false;
    return true;
  }

  @override
  FutureOr<bool> endCommunicationChannel() async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    Logger.debug('Communication channel was cancelled');
    return true;
  }

  @override
  Future<bool> send(OutgoingNearbyMessage message) {
    return NearbyServiceIOSPlatform.instance.send(message);
  }

  Future<String?> getSavedDeviceName() {
    return NearbyServiceIOSPlatform.instance.getSavedDeviceName();
  }

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
      Logger.error(onError);
    }
  }

  void _requireIOSDevice(NearbyDevice device) {
    assert(
      device is NearbyIOSDevice,
      'The Nearby IOS Service can only work with the NearbyIOSDevice and not with ${device.runtimeType}',
    );
  }
}
