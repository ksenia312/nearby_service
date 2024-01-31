part of 'nearby_socket_service.dart';

enum _Commands { ping, pong }

class NearbySocketPingManager {
  Future<bool> checkPing(HttpRequest request) async {
    final body = await _getBody(request);
    return body == _Commands.ping.name;
  }

  Future<bool> checkPong(HttpClientResponse? response) async {
    if (response == null) return false;

    final body = await _getBody(response);
    return body == _Commands.pong.name;
  }

  static Future<String?> _getBody(Stream<List<int>> data) {
    try {
      return utf8.decoder.bind(data).join();
    } catch (e) {
      return Future.value(null);
    }
  }
}
