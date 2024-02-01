import 'package:nearby_service/nearby_service.dart';

///
/// Basic Message Abstraction.
///
abstract class NearbyMessage {
  ///
  /// The basic message contains only [content] - the content
  /// to be sent or received.
  ///
  const NearbyMessage({required this.content});

  ///
  /// Model representing content to be sent or received
  ///
  final NearbyMessageContent content;

  ///
  /// Checks if [content] is not empty
  ///
  bool get isValid {
    return content.isValid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessage &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() {
    return 'NearbyMessage{content: $content}';
  }
}

///
/// The message that will be sent from the current device.
///
class OutgoingNearbyMessage extends NearbyMessage {
  ///
  /// To send a message, in addition to [content], you need to pass [receiver]
  /// to know to whom the message is addressed.
  ///
  const OutgoingNearbyMessage({
    required super.content,
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
      'content': content.toJson(),
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

  @override
  String toString() {
    return 'OutgoingNearbyMessage{receiver: $receiver content:$content}';
  }
}

///
/// Message received by the current device.
///
class ReceivedNearbyMessage extends NearbyMessage {
  ///
  /// The received message contains a [sender] in addition to [content],
  /// to know from whom the message came.
  ///
  const ReceivedNearbyMessage({
    required super.content,
    required this.sender,
  });

  ///
  /// Get [ReceivedNearbyMessage] from [Map].
  ///
  factory ReceivedNearbyMessage.fromJson(Map<String, dynamic>? json) {
    return ReceivedNearbyMessage(
      content: NearbyMessageContent.fromJson(json?['content']),
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
    return 'ReceivedNearbyMessage{sender: $sender content: $content}';
  }
}
