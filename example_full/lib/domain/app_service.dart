import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/utils/files_saver.dart';

import 'app_state.dart';

class AppService extends ChangeNotifier {
  late final _nearbyService = NearbyService.getInstance();

  AppState state = AppState.idle;
  List<NearbyDevice>? peers;
  NearbyDevice? connectedDevice;
  NearbyDeviceInfo? currentDeviceInfo;
  NearbyConnectionAndroidInfo? _connectionAndroidInfo;
  CommunicationChannelState _communicationChannelState =
      CommunicationChannelState.notConnected;
  bool _isIOSBrowser = true;

  String platformVersion = 'Unknown';
  String platformModel = 'Unknown';

  StreamSubscription? _peersSubscription;
  StreamSubscription? _connectedDeviceSubscription;
  StreamSubscription? _connectionInfoSubscription;

  final filesLoadings = <String, int>{};

  @override
  void dispose() {
    stopListeningAll();
    super.dispose();
  }

  Future<void> getPlatformInfo() async {
    platformVersion = await _nearbyService.getPlatformVersion() ?? 'Unknown';
    platformModel = await _nearbyService.getPlatformModel() ?? 'Unknown';
    notifyListeners();
  }

  Future<String> getSavedIOSDeviceName() async {
    return (await _nearbyService.ios?.getSavedDeviceName()) ?? platformModel;
  }

  Future<void> initialize(String? iosDeviceName) async {
    try {
      await _nearbyService.initialize(
        data: NearbyInitializeData(iosDeviceName: iosDeviceName),
      );
      _nearbyService.ios?.getIsBrowserStream().listen((event) {
        _isIOSBrowser = event;
      });
      startListeningCommunicationChannelState();
      updateState(
        Platform.isAndroid ? AppState.permissions : AppState.selectClientType,
      );
    } catch (e, s) {
      _log(e, s);
    } finally {
      notifyListeners();
    }
  }

  Future<void> getCurrentDeviceInfo() async {
    try {
      currentDeviceInfo = await _nearbyService.getCurrentDeviceInfo();
    } catch (e, s) {
      _log(e, s);
    }
  }

  Future<void> requestPermissions() async {
    try {
      final result = await _nearbyService.android?.requestPermissions();
      if (result ?? false) {
        updateState(AppState.checkServices);
      }
    } catch (e, s) {
      _log(e, s);
    }
  }

  Future<bool> checkWifiService() async {
    final result = await _nearbyService.android?.checkWifiService();
    if (result ?? false) {
      updateState(AppState.readyToDiscover);
      startListeningConnectionInfo();
      return true;
    }
    return false;
  }

  Future<void> openServicesSettings() async {
    await _nearbyService.openServicesSettings();
  }

  void setIsBrowser({required bool value}) {
    _nearbyService.ios?.setIsBrowser(value: value);
    updateState(AppState.readyToDiscover);
  }

  Future<bool> hasRunningJobs() async {
    try {
      final result = await _nearbyService.getPeers();
      // if one of devices is connecting, service is busy (android only)
      if (result.any(
        (element) => element.status == NearbyDeviceStatus.connecting,
      )) {
        if (kDebugMode) {
          print('Service has already running jobs');
        }
        return true;
      }
      return false;
    } catch (e, s) {
      _log(e, s);
      return false;
    }
  }

  Future<void> discover() async {
    try {
      await getCurrentDeviceInfo();
      final hasRunning = await hasRunningJobs();
      if (hasRunning) {
        updateState(AppState.discoveringPeers);
      } else {
        final result = await _nearbyService.discover();
        if (result) {
          updateState(AppState.discoveringPeers);
        }
      }
    } on NearbyServiceBusyException catch (_) {
      _logBusyException();
    } catch (e, s) {
      _log(e, s);
    }
  }

  Future<void> stopDiscovery() async {
    try {
      final hasRunning = await hasRunningJobs();
      if (hasRunning) {
        await cancelConnect();
      }
      final result = await _nearbyService.stopDiscovery();
      if (result) {
        updateState(AppState.readyToDiscover);
      }
    } on NearbyServiceBusyException catch (_) {
      _logBusyException();
    } catch (e, s) {
      _log(e, s);
    }
  }

  Future<void> connect(NearbyDevice device) async {
    try {
      await _nearbyService.connectById(device.info.id);
    } on NearbyServiceBusyException catch (_) {
      _logBusyException();
    } catch (e, s) {
      _log(e, s);
    }
    notifyListeners();
  }

  Future<void> disconnect([NearbyDevice? device]) async {
    try {
      await _nearbyService.disconnectById(device?.info.id);
    } on NearbyServiceBusyException catch (_) {
      _logBusyException();
    } catch (e, s) {
      _log(e, s);
    } finally {
      await stopListeningAll();
    }
    notifyListeners();
  }

  Future<void> cancelConnect() async {
    try {
      await _nearbyService.android?.cancelLastConnectionProcess();
    } on NearbyServiceBusyException catch (_) {
      _logBusyException();
    } catch (e, s) {
      _log(e, s);
    }
    notifyListeners();
  }

  Future<void> stopListeningAll() async {
    await endCommunicationChannel();
    await stopListeningConnectedDevice();
    await stopListeningPeers();
    await stopListeningConnectionInfo();
    await stopDiscovery();
  }

  void updateState(AppState state, {bool shouldNotify = true}) {
    this.state = state;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _notify() => notifyListeners();
}

extension GettersExtension on AppService {
  CommunicationChannelState get communicationChannelState =>
      _communicationChannelState;

  bool get isIOSBrowser {
    return _isIOSBrowser;
  }

  bool? get isAndroidGroupOwner {
    return _connectionAndroidInfo?.isGroupOwner;
  }
}

extension ConnectionInfoExtension on AppService {
  void startListeningConnectionInfo() {
    try {
      _connectionInfoSubscription =
          _nearbyService.android?.getConnectionInfoStream().listen(
        (event) async {
          _connectionAndroidInfo = event;
          _notify();
        },
      );
    } catch (e, s) {
      _log(e, s);
    }
    _notify();
  }

  void startListeningCommunicationChannelState() {
    try {
      _connectionInfoSubscription =
          _nearbyService.getCommunicationChannelStateStream().listen(
        (event) async {
          _communicationChannelState = event;
          _notify();
        },
      );
    } catch (e, s) {
      _log(e, s);
    }
    _notify();
  }

  Future<void> stopListeningConnectionInfo() async {
    await _connectionInfoSubscription?.cancel();
    _connectionInfoSubscription = null;
  }
}

extension PeersExtension on AppService {
  Future<void> startListeningPeers() async {
    try {
      _peersSubscription = _nearbyService.getPeersStream().listen(
        (event) {
          peers = event;
          _notify();
        },
      );
      updateState(AppState.streamingPeers);
    } catch (e, s) {
      _log(e, s);
    }
  }

  Future<void> stopListeningPeers() async {
    await _peersSubscription?.cancel();
    peers = null;
    updateState(AppState.discoveringPeers);
  }
}

extension ConnectedDeviceExtension on AppService {
  Future<void> startListeningConnectedDevice(NearbyDevice device) async {
    updateState(AppState.loadingConnection);
    try {
      _connectedDeviceSubscription =
          _nearbyService.getConnectedDeviceStreamById(device.info.id).listen(
        (event) async {
          final wasConnected = connectedDevice?.status.isConnected ?? false;
          final nowConnected = event?.status.isConnected ?? false;
          if (wasConnected && !nowConnected) {
            stopListeningAll();
            return;
          }
          connectedDevice = event;
          if (connectedDevice != null &&
              state != AppState.connected &&
              state != AppState.communicationChannelCreated) {
            updateState(AppState.connected);
          }
          _notify();
        },
      );
    } catch (e) {
      updateState(AppState.streamingPeers, shouldNotify: false);
    }
    _notify();
  }

  Future<void> stopListeningConnectedDevice() async {
    await _connectedDeviceSubscription?.cancel();
    await _nearbyService.endCommunicationChannel();
    _connectedDeviceSubscription = null;
    connectedDevice = null;
    _notify();
  }
}

extension CommunicationChannelExtension on AppService {
  Future<void> startCommunicationChannel({
    ValueChanged<ReceivedNearbyMessage>? listener,
    ValueChanged<ReceivedNearbyFilesPack>? onFilesSaved,
  }) async {
    final messagesListener = NearbyServiceMessagesListener(
      onCreated: () {
        updateState(AppState.communicationChannelCreated);
      },
      onData: (event) {
        listener?.call(event);
      },
      onError: (e, [StackTrace? s]) {
        stopListeningAll();
      },
    );
    final filesListener = NearbyServiceFilesListener(
      onData: (event) async {
        final files = await FilesSaver.savePack(event);
        onFilesSaved?.call(
          ReceivedNearbyFilesPack(
            id: event.id,
            sender: event.sender,
            files: files,
          ),
        );
      },
    );

    await _nearbyService.startCommunicationChannel(
      NearbyCommunicationChannelData(
        connectedDevice!.info.id,
        messagesListener: messagesListener,
        filesListener: filesListener,
      ),
    );
  }

  Future<void> endCommunicationChannel() async {
    try {
      await _nearbyService.endCommunicationChannel();
    } catch (e, s) {
      _log(e, s);
    }
    _notify();
  }
}

extension MessagingExtension on AppService {
  void sendTextRequest(String message) {
    if (connectedDevice == null) return;
    _nearbyService.send(
      OutgoingNearbyMessage(
        content: NearbyMessageTextRequest.create(value: message),
        receiver: connectedDevice!.info,
      ),
    );
  }

  void sendFilesRequest(List<String> paths) {
    if (connectedDevice == null) return;
    _nearbyService.send(
      OutgoingNearbyMessage(
        content: NearbyMessageFilesRequest.create(
          files: [
            ...paths.map((e) => NearbyFileInfo(path: e)),
          ],
        ),
        receiver: connectedDevice!.info,
      ),
    );
  }

  void sendTextResponse(String requestId) {
    if (connectedDevice == null) return;

    _nearbyService.send(
      OutgoingNearbyMessage(
        receiver: connectedDevice!.info,
        content: NearbyMessageTextResponse(id: requestId),
      ),
    );
  }

  void sendFilesResponse(
    NearbyMessageFilesRequest request, {
    required bool isAccepted,
  }) {
    if (connectedDevice == null) return;
    _nearbyService.send(
      OutgoingNearbyMessage(
        receiver: connectedDevice!.info,
        content: NearbyMessageFilesResponse(
          id: request.id,
          isAccepted: isAccepted,
        ),
      ),
    );
    if (isAccepted) {
      setFilesLoading(request);
    }
  }

  void setFilesLoading(NearbyMessageFilesRequest request) {
    filesLoadings[request.id] = request.files.length;
    _notify();
  }

  void endFilesLoading(ReceivedNearbyFilesPack pack) {
    filesLoadings.remove(pack.id);
    _notify();
  }
}

extension LoggingExtension on AppService {
  void _log(e, StackTrace s) {
    if (kDebugMode) {
      print('$e, \nStacktrace: $s');
    }
  }

  void _logBusyException() {
    if (kDebugMode) {
      print(
        'Nearby service is busy, wait a little and retry (You can implement retry in your code)',
      );
    }
  }
}
