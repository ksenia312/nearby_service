import 'dart:io';

enum AppState {
  idle,
  permissions,
  checkServices,
  selectClientType,
  readyToDiscover,
  discoveringPeers,
  streamingPeers,
  loadingConnection,
  connected,
  communicationChannelCreated;

  static final List<AppState> androidSteps = [
    AppState.idle,
    AppState.permissions,
    AppState.checkServices,
    AppState.readyToDiscover,
    AppState.discoveringPeers,
    AppState.streamingPeers,
    AppState.loadingConnection,
    AppState.connected,
    AppState.communicationChannelCreated,
  ];
  static final List<AppState> iosSteps = [
    AppState.idle,
    AppState.selectClientType,
    AppState.readyToDiscover,
    AppState.discoveringPeers,
    AppState.streamingPeers,
    AppState.loadingConnection,
    AppState.connected,
    AppState.communicationChannelCreated,
  ];

  static final List<AppState> steps = [
    if (Platform.isAndroid) ...androidSteps,
    if (Platform.isIOS) ...iosSteps,
  ];

  int get step {
    return steps.indexOf(this);
  }
}
