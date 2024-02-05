import 'package:nearby_service/nearby_service.dart';

///
/// Abstraction for the message content.
/// The [NearbyMessageContentType] is used to
/// determine, what type of content is it.
///
abstract base class NearbyMessageContent {
  const NearbyMessageContent();

  ///
  /// Contains the conditional logic of creating [NearbyMessageFilesRequest],
  /// [NearbyMessageFilesResponse] or [NearbyMessageTextContent]
  /// by `type` field of [json].
  ///
  static C fromJson<C extends NearbyMessageContent>(
    Map<String, dynamic>? json,
  ) {
    try {
      final type = NearbyMessageContentType.values.firstWhere(
        (e) => e.name == json?['type'],
      );
      if (type.isText) {
        return NearbyMessageTextContent.fromJson(json) as C;
      } else if (type.isFilesRequest) {
        return NearbyMessageFilesRequest.fromJson(json) as C;
      } else if (type.isFilesResponse) {
        return NearbyMessageFilesResponse.fromJson(json) as C;
      } else {
        throw NearbyServiceException.unsupportedDecoding(json);
      }
    } catch (e) {
      throw NearbyServiceException(e);
    }
  }

  NearbyMessageContentType get _type {
    final type = byType(
      onText: (_) => NearbyMessageContentType.text,
      onFilesRequest: (_) => NearbyMessageContentType.filesRequest,
      onFilesResponse: (_) => NearbyMessageContentType.filesResponse,
    );
    if (type != null) {
      return type;
    }
    throw NearbyServiceException(
      'Unknown type on NearbyMessageContent - $runtimeType',
    );
  }

  ///
  /// Check for the content if it is valid for sending or receiving.
  ///
  bool get isValid;

  ///
  /// * The [onText] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageTextContent] if is a text.
  ///
  /// * The [onFilesRequest] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageFilesRequest] if is a files pack request.
  ///
  /// * The [onFilesResponse] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageFilesResponse] if is a files pack response.
  ///
  T? byType<T>({
    T Function(NearbyMessageTextContent)? onText,
    T Function(NearbyMessageFilesRequest)? onFilesRequest,
    T Function(NearbyMessageFilesResponse)? onFilesResponse,
  }) {
    if (this is NearbyMessageTextContent && onText != null) {
      return onText(this as NearbyMessageTextContent);
    } else if (this is NearbyMessageFilesRequest && onFilesRequest != null) {
      return onFilesRequest(this as NearbyMessageFilesRequest);
    } else if (this is NearbyMessageFilesResponse && onFilesResponse != null) {
      return onFilesResponse(this as NearbyMessageFilesResponse);
    }
    return null;
  }

  ///
  /// Gets [Map] from [NearbyMessageContent]
  ///
  Map<String, dynamic> toJson() {
    return {'type': _type.name};
  }
}
