import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(const App());
}

enum AppState { idle, ready, discovering, connected }

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
  final _nearbyService = NearbyService.getInstance(
    logLevel: NearbyServiceLogLevel.debug,
  );
  AppState _state = AppState.idle;

  bool _isIosBrowser = true;
  List<NearbyDevice> _peers = [];
  NearbyDevice? _connectedDevice;
  StreamSubscription? _peersSubscription;

  List<PlatformFile> _pickedFiles = [];
  String _message = '';
  Timer? _connectionCheckTimer;

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
          if (Platform.isIOS)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'You are ${_isIosBrowser ? 'Browser' : 'Advertiser'}',
                  ),
                ),
                Switch(
                  value: _isIosBrowser,
                  onChanged: (value) => setState(() => _isIosBrowser = value),
                ),
              ],
            ),
          ElevatedButton(
            onPressed: _preparePlatforms,
            child: const Text('Prepare Platforms'),
          ),
        ],
      );
    } else if (_state == AppState.ready) {
      return ElevatedButton(
        onPressed: _discovery,
        child: const Text('Start discovery'),
      );
    } else if (_state == AppState.discovering) {
      return ListView(
        children: [
          if (Platform.isIOS)
            Text(
              'You are ${_isIosBrowser ? 'Browser' : 'Advertiser'}',
            ),
          ..._peers.map(
            (e) => ListTile(
              title: Text(
                '${_isIosBrowser ? 'Found device' : 'Pending invitation'} | ${e.info.displayName} | ${e.status.name}',
              ),
              onTap: () => _connect(e),
              tileColor: Colors.blueAccent,
              textColor: Colors.white,
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
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _connectedDevice!.info.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: _disconnect,
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _message = value),
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _send(NearbyMessageTextRequest.create(value: _message));
                  },
                  child: const Text('Send message'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                    );
                    if (result != null) {
                      setState(
                        () => _pickedFiles = result.files,
                      );
                    }
                  },
                  child: const Text('Pick the files'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _send(
                      NearbyMessageFilesRequest.create(
                        files: [
                          ..._pickedFiles.map(
                            (e) => NearbyFileInfo(path: e.path!),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Send files'),
                ),
                const Text('Picked files:', style: TextStyle(fontSize: 16)),
                ..._pickedFiles.map((e) => Text(e.name)),
              ],
            )
          ],
        ),
      );
    }
    return Container();
  }

  Future<void> _initialize() async {
    await _nearbyService.initialize();
  }

  Future<void> _preparePlatforms() async {
    bool result;

    if (Platform.isAndroid) {
      final isGranted = await _nearbyService.android?.requestPermissions();
      final wifiEnabled = await _nearbyService.android?.checkWifiService();
      result = (isGranted ?? false) && (wifiEnabled ?? false);
    } else if (Platform.isIOS) {
      _nearbyService.ios?.setIsBrowser(value: _isIosBrowser);
      result = true;
    } else {
      result = false;
    }
    if (result) {
      setState(() {
        _state = AppState.ready;
      });
    }
  }

  Future<void> _discovery() async {
    final result = await _nearbyService.discover();
    if (result) {
      setState(() {
        _state = AppState.discovering;
      });
      _peersSubscription = _nearbyService.getPeersStream().listen((event) {
        setState(() {
          _peers = event;
        });
      });
    }
  }

  Future<void> _connect(NearbyDevice device) async {
    final result = await _nearbyService.connect(device);
    if (result) {
      _connectionCheckTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) {
          try {
            final selectedDevice = _peers.firstWhere(
              (element) => element.info.id == device.info.id,
            );
            if (selectedDevice.status.isConnected) {
              _connectionCheckTimer?.cancel();
              _connectionCheckTimer = null;
              _nearbyService.startCommunicationChannel(
                NearbyCommunicationChannelData(
                  device.info.id,
                  messagesListener: NearbyServiceMessagesListener(
                    onCreated: () {
                      setState(() {
                        _connectedDevice = device;
                        _state = AppState.connected;
                      });
                    },
                    onData: _messagesListener,
                    onError: (e, [StackTrace? s]) {
                      setState(() {
                        _connectedDevice = null;
                        _state = AppState.discovering;
                      });
                    },
                    onDone: () {
                      setState(() {
                        _connectedDevice = null;
                        _state = AppState.discovering;
                      });
                    },
                  ),
                  filesListener: NearbyServiceFilesListener(
                    onData: _filesListener,
                  ),
                ),
              );
            }
          } finally {}
        },
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      await _nearbyService.disconnect(_connectedDevice!);
    } finally {
      await _nearbyService.endCommunicationChannel();
      await _nearbyService.stopDiscovery();
      await _peersSubscription?.cancel();
      setState(() {
        _state = AppState.idle;
      });
    }
  }

  void _messagesListener(ReceivedNearbyMessage<NearbyMessageContent> message) {
    if (_connectedDevice == null) return;
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

  void _filesListener(ReceivedNearbyFilesPack pack) {
    FilesSaver.savePack(pack).then(
      (value) => AppSnackBar.show(context, title: 'Files pack was saved'),
    );
  }

  Future<void> _send(NearbyMessageContent content) async {
    if (_connectedDevice == null) return;

    await _nearbyService.send(
      OutgoingNearbyMessage(content: content, receiver: _connectedDevice!.info),
    );
  }
}

class AppSnackBar {
  AppSnackBar._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? actionName,
    VoidCallback? onAcceptAction,
  }) async {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        if (subtitle != null) Text(subtitle),
      ],
    );
    final action = onAcceptAction != null && actionName != null
        ? SnackBarAction(
            label: actionName,
            onPressed: onAcceptAction,
          )
        : null;
    final messenger = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        action: action,
      ),
    );
    return messenger.closed.then((value) => null);
  }
}

class FilesSaver {
  FilesSaver._();

  static Future<List<NearbyFileInfo>> savePack(
    ReceivedNearbyFilesPack pack,
  ) async {
    final files = <NearbyFileInfo>[];
    final directory = Platform.isAndroid
        ? Directory('storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    for (final nearbyFile in pack.files) {
      final newFile = await File(nearbyFile.path).copy(
        '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.${nearbyFile.extension}',
      );
      if (!await newFile.exists()) {
        await newFile.create();
      }
      files.add(NearbyFileInfo(path: newFile.path));
    }
    return files;
  }
}
