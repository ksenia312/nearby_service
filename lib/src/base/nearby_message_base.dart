import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

///
/// Basic Message Abstraction.
///
abstract base class NearbyMessage<C extends NearbyMessageContent> {
  ///
  /// The basic message contains only [content] - the content
  /// to be sent or received.
  ///
  const NearbyMessage({required this.content});

  ///
  /// Model representing content to be sent or received
  ///
  final C content;

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

  ///
  /// Get [Map] from [NearbyMessage].
  ///
  @mustCallSuper
  Map<String, dynamic> toJson() => {'content': content.toJson()};
}
