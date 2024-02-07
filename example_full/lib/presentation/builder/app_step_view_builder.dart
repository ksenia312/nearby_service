import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_state.dart';
import 'package:nearby_service_example_full/presentation/view/view.dart';

class AppStepViewBuilder {
  const AppStepViewBuilder({required this.state});

  final AppState state;

  Widget buildContent({
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) {
    return switch (state) {
      (AppState.idle) => const IdleView(),
      (AppState.permissions) => const PermissionsView(),
      (AppState.checkServices) => const CheckServiceView(),
      (AppState.selectClientType) => const SelectClientTypeView(),
      (AppState.readyToDiscover) => const ReadyView(),
      (AppState.discoveringPeers) => const DiscoveryView(),
      (AppState.streamingPeers) => const StreamingPeersView(),
      (AppState.loadingConnection) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      (AppState.connected) => ConnectedView(
          scaffoldKey: scaffoldKey,
        ),
      (AppState.communicationChannelCreated) => const CommunicationView(),
    };
  }

  Widget buildTitle() {
    return Text(
      switch (state) {
        AppState.idle => "Let's start!",
        AppState.permissions => "Provide permissions",
        AppState.checkServices => "Check services",
        AppState.selectClientType =>
          'Do you want to find your friend from this device?',
        AppState.readyToDiscover => "Ready to discover!",
        AppState.discoveringPeers => "Discovering devices...",
        AppState.streamingPeers => "Peers stream got!",
        AppState.loadingConnection => "Loading your connection",
        AppState.connected => "Connected!",
        AppState.communicationChannelCreated => "You can communicate!",
      },
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget? buildSubtitle() {
    final subtitle = switch (state) {
      AppState.selectClientType =>
        'Click "Yes" if you will search, click "No" if you will wait for your friend to connect',
      _ => null,
    };
    return subtitle != null ? Text(subtitle) : null;
  }
}
