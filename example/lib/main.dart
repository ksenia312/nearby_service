import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

/// All UI components and utilities are moved out of main
/// to focus on the nearby_service plugin.
/// If you are interested to see them,
/// see https://github.com/ksenia312/nearby_service/blob/main/example/lib/.
import 'components/connected_device_view.dart';
import 'components/files_messaging_view.dart';
import 'components/darwin_role_selector.dart';
import 'components/peer_widget.dart';
import 'components/text_messaging_view.dart';
import 'utils/app_snack_bar.dart';
import 'utils/file_saver.dart';

/// Short example variant for pub.dev
/// See the full example at
/// https://github.com/ksenia312/nearby_service/tree/main/example_full
Future<void> main() async {
  runApp(const App());
}

/// Simplified application states, main 3:
/// - Preparatory
/// - Device search
/// - Communicating with the connected device
enum AppState { idle, discovering, connected }

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Service Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Nearby Service Example')),
        body: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(20),
          child: const AppBody(),
        ),
      ),
    );
  }
}

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  /// Our service
  late final _nearbyService = NearbyService.getInstance(
    /// Define log level here
    logLevel: NearbyServiceLogLevel.debug,
  );

  AppState _state = AppState.idle;

  /// Browser OR Advertiser for IOS/MacOS
  bool _isDarwinBrowser = true;

  /// List of discovered devices
  List<NearbyDevice> _peers = [];
  StreamSubscription? _peersSubscription;
  CommunicationChannelState _communicationChannelState =
      CommunicationChannelState.notConnected;

  /// Temporary solution to check the connection,
  /// use [NearbyService.getConnectedDeviceStreamById] for this purpose
  /// in your application
  Timer? _connectionCheckTimer;
  NearbyDevice? _connectedDevice;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _peersSubscription?.cancel();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == AppState.idle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Platform.isIOS || Platform.isMacOS)
            DarwinRoleSelector(
              isDarwinBrowser: _isDarwinBrowser,
              onSelect: (value) => setState(() => _isDarwinBrowser = value),
            ),
          ElevatedButton(
            onPressed: _startProcess,
            child: const Text('Start'),
          ),
        ],
      );
    } else if (_state == AppState.discovering) {
      return ListView(
        children: [
          if (Platform.isIOS || Platform.isMacOS)
            Text('You are ${_isDarwinBrowser ? 'Browser' : 'Advertiser'}'),
          if (_peers.isEmpty) const Text('Searching for peers...'),
          ..._peers.map(
            (e) => PeerWidget(
              device: e,
              isDarwinBrowser: _isDarwinBrowser,
              onConnect: _connect,
              communicationChannelState: _communicationChannelState,
            ),
          ),
        ],
      );
    } else if (_state == AppState.connected) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview of the connected device
            ConnectedDeviceView(
              device: _connectedDevice!,
              onDisconnect: _disconnect,
            ),
            const SizedBox(height: 50),
            // Send messages section
            TextMessagingView(
              onSend: (message) => _send(
                NearbyMessageTextRequest.create(value: message),
              ),
            ),

            const SizedBox(height: 50),
            // Send files section
            FilesMessagingView(
              onSend: (files) {
                _send(
                  NearbyMessageFilesRequest.create(files: files),
                );
              },
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Future<void> _initialize() async {
    await _nearbyService.initialize();
  }

  Future<void> _startProcess() async {
    final platformsReady = await _checkPlatforms();
    if (platformsReady) {
      await _discover();
    }
  }

  Future<bool> _checkPlatforms() async {
    if (Platform.isAndroid) {
      final isGranted = await _nearbyService.android?.requestPermissions();
      final wifiEnabled = await _nearbyService.android?.checkWifiService();
      return (isGranted ?? false) && (wifiEnabled ?? false);
    } else if (Platform.isIOS || Platform.isMacOS) {
      _nearbyService.darwin?.setIsBrowser(value: _isDarwinBrowser);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _discover() async {
    final result = await _nearbyService.discover();
    if (result) {
      setState(() {
        _state = AppState.discovering;
      });
      _peersSubscription = _nearbyService.getPeersStream().listen((event) {
        setState(() {
          _peers = event;
          // Check and filter your peers here
        });
      });
    }
  }

  Future<void> _connect(NearbyDevice device) async {
    // Be careful with already connected devices,
    // double connection may be unnecessary
    final result = await _nearbyService.connectById(device.info.id);
    if (result || device.status.isConnected) {
      final channelStarting = _tryCommunicate(device);
      if (!channelStarting) {
        _connectionCheckTimer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => _tryCommunicate(device),
        );
      }
    }
  }

  bool _tryCommunicate(NearbyDevice device) {
    NearbyDevice? selectedDevice;

    try {
      selectedDevice = _peers.firstWhere(
        (element) => element.info.id == device.info.id,
      );
    } catch (_) {
      return false;
    }

    if (selectedDevice.status.isConnected) {
      try {
        _startCommunicationChannel(device);
      } finally {
        _connectionCheckTimer?.cancel();
        _connectionCheckTimer = null;
      }
      return true;
    }
    return false;
  }

  void _startCommunicationChannel(NearbyDevice device) {
    if (_communicationChannelState != CommunicationChannelState.notConnected) {
      // channel is loading or already connected
      return;
    }
    // start listening communication channel state
    _nearbyService.getCommunicationChannelStateStream().listen((event) {
      _communicationChannelState = event;
    });
    _nearbyService.startCommunicationChannel(
      NearbyCommunicationChannelData(
        device.info.id,
        filesListener: NearbyServiceFilesListener(
          onData: (pack) => _filesListener(Scaffold.of(context).context, pack),
        ),
        messagesListener: NearbyServiceMessagesListener(
          onData: _messagesListener,
          onCreated: () {
            setState(() {
              _connectedDevice = device;
              _state = AppState.connected;
            });
          },
          onError: (e, [StackTrace? s]) {
            setState(() {
              _connectedDevice = null;
              _state = AppState.idle;
            });
          },
          onDone: () {
            setState(() {
              _connectedDevice = null;
              _state = AppState.idle;
            });
          },
        ),
      ),
    );
  }

  Future<void> _disconnect() async {
    try {
      await _nearbyService.disconnectById(_connectedDevice!.info.id);
    } finally {
      await _nearbyService.endCommunicationChannel();
      await _nearbyService.stopDiscovery();
      await _peersSubscription?.cancel();
      setState(() {
        _peers = [];
        _state = AppState.idle;
      });
    }
  }

  void _messagesListener(ReceivedNearbyMessage<NearbyMessageContent> message) {
    if (_connectedDevice == null) return;
    // Very useful stuff! Process messages according to the type of content
    message.content.byType(
      onTextRequest: (request) {
        AppSnackBar.show(
          context,
          title: request.value,
          subtitle: message.sender.displayName,
        ).whenComplete(
          () => _send(NearbyMessageTextResponse(id: request.id)),
        );
      },
      onTextResponse: (response) {
        AppSnackBar.show(
          context,
          title: 'Message ${response.id} was delivered',
          subtitle: message.sender.displayName,
        );
      },
      onFilesRequest: (request) {
        AppSnackBar.show(
          context,
          title: 'Request to receive ${request.files.length} files',
          subtitle: message.sender.displayName,
          actionName: 'Accept the files?',
          onAcceptAction: () {
            _send(
              NearbyMessageFilesResponse(id: request.id, isAccepted: true),
            );
          },
        );
      },
      onFilesResponse: (response) {
        AppSnackBar.show(
          context,
          title: 'Response ${response.id} for the files '
              '${response.isAccepted ? 'is accepted' : 'was denied'}',
          subtitle: message.sender.displayName,
        );
      },
    );
  }

  Future<void> _filesListener(
    BuildContext context,
    ReceivedNearbyFilesPack pack,
  ) async {
    await FilesSaver.savePack(pack);
    if (context.mounted) {
      AppSnackBar.show(context, title: 'Files pack was saved');
    }
  }

  Future<void> _send(NearbyMessageContent content) async {
    if (_connectedDevice == null) return;
    await _nearbyService.send(
      OutgoingNearbyMessage(
        content: content,
        receiver: _connectedDevice!.info,
      ),
    );
  }
}
