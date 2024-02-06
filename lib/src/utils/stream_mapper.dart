import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

abstract class MessagesStreamMapper {
  static ReceivedNearbyMessage replaceId(
    ReceivedNearbyMessage message,
    String? id,
  ) {
    if (id != null) {
      return ReceivedNearbyMessage(
        content: message.content,
        sender: NearbyDeviceInfo(
          id: id,
          displayName: message.sender.displayName,
        ),
      );
    }
    throw NearbyServiceException('The provided ID does not exist');
  }

  static ReceivedNearbyMessage? toMessage(dynamic event) {
    try {
      final decoded = JSONDecoder.decodeMap(event);
      if (decoded == null) return null;

      return ReceivedNearbyMessage.fromJson(decoded);
    } catch (e) {
      throw NearbyServiceException(
        'Can\'t convert $event to ReceivedNearbyMessage',
      );
    }
  }
}

abstract class ResourcesStreamMapper {
  static ReceivedNearbyFilesPack? toFilesPack(dynamic event) {
    try {
      final decoded = JSONDecoder.decodeMap(event);
      if (decoded == null) return null;

      return ReceivedNearbyFilesPack.fromJson(decoded);
    } catch (e) {
      throw NearbyServiceException(
        'Can\'t convert $event to ReceivedNearbyMessage',
      );
    }
  }
}
