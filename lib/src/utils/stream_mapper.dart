import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

import 'logger.dart';

abstract class MessagesStreamMapper {
  static ReceivedNearbyMessage replaceId(
    ReceivedNearbyMessage message,
    String id,
  ) {
    return ReceivedNearbyMessage(
      value: message.value,
      sender: NearbyDeviceInfo(
        id: id,
        displayName: message.sender.displayName,
      ),
    );
  }

  static ReceivedNearbyMessage? toMessage(dynamic event) {
    try {
      final decoded = JSONDecoder.decodeMap(event);
      return ReceivedNearbyMessage.fromJson(decoded);
    } catch (e) {
      Logger.debug(
        'Can\'t convert $event to ReceivedNearbyMessage',
      );
    }
    return null;
  }
}
