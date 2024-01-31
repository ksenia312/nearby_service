import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/logger.dart';

abstract class NearbyMessage {
  const NearbyMessage({required this.value});

  final String value;
}

class OutgoingNearbyMessage extends NearbyMessage {
  const OutgoingNearbyMessage({
    required super.value,
    required this.receiver,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': value,
      'receiver': receiver.toJson(),
    };
  }

  final NearbyDeviceInfo receiver;
}

class ReceivedNearbyMessage extends NearbyMessage {
  const ReceivedNearbyMessage({
    required super.value,
    required this.sender,
  });

  factory ReceivedNearbyMessage.fromJson(Map<String, dynamic>? json) {
    try {
      return ReceivedNearbyMessage(
        value: json?['message'] ?? '',
        sender: NearbyDeviceInfo.fromJson(json?['sender']),
      );
    } catch (e) {
      Logger.error(e);
      throw NearbyServiceException('Can\'t map to device $json');
    }
  }

  final NearbyDeviceInfo sender;
}
