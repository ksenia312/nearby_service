///
/// The status of the communication channel for data exchange.
/// Use it to determine if you can send data over the communication channel or not.
///
enum CommunicationChannelState {
  notConnected,
  loading,
  connected;

  bool get isNotConnected => this == CommunicationChannelState.notConnected;

  bool get isLoading => this == CommunicationChannelState.loading;

  bool get isConnected => this == CommunicationChannelState.connected;
}
