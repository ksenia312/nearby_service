import 'package:nearby_service/nearby_service.dart';

extension ChannalPreviewName on CommunicationChannelState {
  String get previewName {
    return switch (this) {
      CommunicationChannelState.notConnected => 'Not connected',
      CommunicationChannelState.loading => 'Connecting',
      CommunicationChannelState.connected => 'Connected',
    };
  }
}
