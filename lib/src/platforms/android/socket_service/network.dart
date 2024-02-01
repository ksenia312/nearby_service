part of 'nearby_socket_service.dart';

class _Protocols {
  static const http = 'http://';
  static const ws = 'ws://';
}

class _Urls {
  static const ws = '/ws';
}

class NearbyServiceNetwork {
  final _httpClient = HttpClient();
  final _random = Random();

  Future<HttpClientResponse?> pingServer({
    required String address,
    required int port,
  }) async {
    try {
      final url = Uri.parse('${_Protocols.http}$address:$port/');
      final request = (await _httpClient.postUrl(url))
        ..write(_Commands.ping.name);
      final response = await request.close();
      return response;
    } catch (e) {
      Logger.error('Server is unreachable: $e');
      return null;
    }
  }

  void pongClient(HttpRequest request) {
    request.response
      ..write(_Commands.pong.name)
      ..close();
    Logger.debug('Sent pong to client');
  }

  Future<HttpServer?> startServer({
    required String ownerIpAddress,
    required int port,
  }) async {
    try {
      final url = '${_Protocols.ws}$ownerIpAddress:$port';
      Logger.debug('Starting server on $url');
      var server = await HttpServer.bind(
        ownerIpAddress,
        port,
        shared: true,
      );
      Logger.info('Server running on $url');
      return server;
    } catch (e) {
      throw NearbyServiceException('Error starting socket: $e');
    }
  }

  Future<WebSocket?> connectToSocket({
    required String ownerIpAddress,
    required int port,
  }) async {
    try {
      final connectionId = _random.nextInt(1000) + 100;
      final url =
          '${_Protocols.ws}$ownerIpAddress:$port${_Urls.ws}?as=$connectionId';
      Logger.debug('Connecting to $url');
      final socket = await WebSocket.connect(url);
      Logger.info('Connected to $url');
      return socket;
    } catch (e) {
      throw NearbyServiceException('Error connecting to server: $e');
    }
  }
}
