import 'dart:io';

import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/json_decoder.dart';

abstract class MessagesStreamMapper {
  static ReceivedNearbyMessage replaceId(
    ReceivedNearbyMessage message,
    String id,
  ) {
    return ReceivedNearbyMessage(
      content: message.content,
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
      throw NearbyServiceException(
        'Can\'t convert $event to ReceivedNearbyMessage',
      );
    }
  }
}

abstract class ResourcesStreamMapper {
  static List<NearbyFile>? toFiles(dynamic event) {
    try {
      final decoded = JSONDecoder.decodeList(event);
      final infoList = [
        ...?decoded?.map(
          (e) => NearbyFileInfo.fromJson(e as Map<String, dynamic>),
        )
      ];
      return [
        ...infoList.map((e) => NearbyFile(info: e, file: File(e.path))),
      ];
    } catch (e) {
      throw NearbyServiceException(
        'Can\'t convert $event to ReceivedNearbyMessage',
      );
    }
  }
}
