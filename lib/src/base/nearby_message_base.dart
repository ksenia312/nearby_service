import 'package:nearby_service/nearby_service.dart';

///
/// Basic Message Abstraction.
///
abstract base class NearbyMessageBase<Content extends NearbyMessageContentBase> {
  ///
  /// The basic message contains only [content] - the content
  /// to be sent or received.
  ///
  const NearbyMessageBase({required this.content});

  ///
  /// Model representing content to be sent or received
  ///
  final Content content;

  ///
  /// Checks if [content] is not empty
  ///
  bool get isValid {
    return content.isValid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageBase &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() {
    return 'NearbyMessage{content: $content}';
  }
}
