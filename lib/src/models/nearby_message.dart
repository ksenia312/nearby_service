import 'package:nearby_service/nearby_service.dart';

///
/// Basic Message Abstraction.
///
abstract class NearbyMessage {
  ///
  /// The basic message contains only [value] - the content
  /// to be sent or received.
  ///
  const NearbyMessage({required this.value});

  final String value;

  ///
  /// Checks if [value] is not empty
  ///
  bool get isValid {
    return value.isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessage &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'NearbyMessage{value: $value}';
  }
}

///
/// The message that will be sent from the current device.
///
class OutgoingNearbyMessage extends NearbyMessage {
  ///
  /// To send a message, in addition to [value], you need to pass [receiver]
  /// to know to whom the message is addressed.
  ///
  const OutgoingNearbyMessage({
    required super.value,
    required this.receiver,
  });

  ///
  /// Data of the user to whom the message is addressed.
  ///
  final NearbyDeviceInfo receiver;

  ///
  /// Get [Map] from [OutgoingNearbyMessage].
  ///
  Map<String, dynamic> toJson() {
    return {
      'message': value,
      'receiver': receiver.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is OutgoingNearbyMessage &&
          runtimeType == other.runtimeType &&
          receiver == other.receiver;

  @override
  int get hashCode => super.hashCode ^ receiver.hashCode;
}

///
/// Message received by the current device.
///
class ReceivedNearbyMessage extends NearbyMessage {
  ///
  /// The received message contains a [sender] in addition to [value],
  /// to know from whom the message came.
  ///
  const ReceivedNearbyMessage({
    required super.value,
    required this.sender,
  });

  ///
  /// Get [ReceivedNearbyMessage] from [Map].
  ///
  factory ReceivedNearbyMessage.fromJson(Map<String, dynamic>? json) {
    return ReceivedNearbyMessage(
      value: json?['message'] ?? '',
      sender: NearbyDeviceInfo.fromJson(json?['sender']),
    );
  }

  ///
  /// Data of the user from whom the message came.
  ///
  final NearbyDeviceInfo sender;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ReceivedNearbyMessage &&
          runtimeType == other.runtimeType &&
          sender == other.sender;

  @override
  int get hashCode => super.hashCode ^ sender.hashCode;

  @override
  String toString() {
    return 'ReceivedNearbyMessage{sender: $sender}';
  }
}
