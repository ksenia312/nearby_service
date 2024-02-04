import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/random.dart';

///
/// Type of the message.
///
/// If [text], it will be a text message.
/// If [filesRequest], it will be a files pack request.
/// After accepting the request,
/// user can get files bytes stream from connected device.
///
enum NearbyMessageContentType {
  text,
  filesRequest,
  filesResponse;

  ///
  /// Checks if this is [NearbyMessageContentType.text]
  ///
  bool get isText {
    return this == NearbyMessageContentType.text;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.filesRequest]
  ///
  bool get isFilesRequest {
    return this == NearbyMessageContentType.filesRequest;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.filesResponse]
  ///
  bool get isFilesResponse {
    return this == NearbyMessageContentType.filesResponse;
  }
}

///
/// Abstraction for the message content.
/// Contains [_type] to determine, what type of content is it.
///
abstract class NearbyMessageContent {
  const NearbyMessageContent(this._type);

  ///
  /// Contains the conditional logic of creating [NearbyMessageFilesRequest],
  /// [NearbyMessageFilesResponse] or [NearbyMessageTextContent]
  /// by `type` field of [json].
  ///
  factory NearbyMessageContent.fromJson(Map<String, dynamic>? json) {
    try {
      final type = NearbyMessageContentType.values.firstWhere(
        (e) => e.name == json?['type'],
      );
      if (type.isText) {
        return NearbyMessageTextContent.fromJson(json);
      } else if (type.isFilesRequest) {
        return NearbyMessageFilesRequest.fromJson(json);
      } else if (type.isFilesResponse) {
        return NearbyMessageFilesResponse.fromJson(json);
      } else {
        throw NearbyServiceException.unsupportedDecoding(json);
      }
    } catch (e) {
      throw NearbyServiceException(e);
    }
  }

  final NearbyMessageContentType _type;

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

///
/// Nearby message Text content.
///
/// Contains [value] - the message to be sent or received.
///
class NearbyMessageTextContent extends NearbyMessageContent {
  const NearbyMessageTextContent({required this.value})
      : super(
          NearbyMessageContentType.text,
        );

  ///
  /// Gets [NearbyMessageTextContent] from [json]
  ///
  factory NearbyMessageTextContent.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageTextContent(
      value: json?['value'] ?? '',
    );
  }

  ///
  /// The message to be sent or received
  ///
  final String value;

  @override
  bool get isValid => value.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageTextContent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'NearbyMessageTextContent{value: $value}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      ...super.toJson(),
    };
  }
}

///
/// Sealed class for files content in NearbyMessage.
///
sealed class NearbyMessageFilesContent extends NearbyMessageContent {
  ///
  /// Here [_type] = [NearbyMessageContentType.filesResponse] or
  /// [_type] =  [NearbyMessageContentType.filesRequest]
  ///
  /// Also [NearbyMessageFilesContent] contains [id] of the files pack and
  /// list of [NearbyFileInfo] to determine the files.
  ///
  const NearbyMessageFilesContent(
    super.type, {
    required this.id,
    required this.files,
  });

  ///
  /// Info about the files to be sent or received.
  ///
  final List<NearbyFileInfo> files;

  ///
  /// ID of this files pack
  ///
  final String id;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'files': [
        ...files.map((e) => e.toJson()),
      ],
      ...super.toJson(),
    };
  }

  @override
  bool get isValid =>
      files.isNotEmpty &&
      files.every(
        (element) => element.path.isNotEmpty,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageFilesContent &&
          runtimeType == other.runtimeType &&
          files == other.files &&
          id == other.id;

  @override
  int get hashCode => files.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'NearbyMessageFilesContent{files: $files, id: $id}';
  }
}

///
/// Nearby message File Request. Used for file sending requests.
/// Does not contain files' bytes!
///
class NearbyMessageFilesRequest extends NearbyMessageFilesContent {
  const NearbyMessageFilesRequest._({
    required super.id,
    required super.files,
  }) : super(
          NearbyMessageContentType.filesRequest,
        );

  ///
  /// Basic constructor with [files] to be sent or received.
  ///
  NearbyMessageFilesRequest({required super.files})
      : super(
          NearbyMessageContentType.filesRequest,
          id: RandomUtils.instance.nextInt(1000000, 9999999).toString(),
        );

  ///
  /// Gets [NearbyMessageFilesRequest] from [json].
  ///
  factory NearbyMessageFilesRequest.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFilesRequest._(
      id: json?['id'] ?? '',
      files: [
        ...?(json?['files'] as List?)?.map(
          (e) => NearbyFileInfo.fromJson(e),
        ),
      ],
    );
  }

  @override
  String toString() {
    return 'NearbyMessageFileRequest{id: $id, files: $files}';
  }
}

///
/// Nearby message File Response. Used for file sending responses.
/// Does not contain files' bytes!
///
class NearbyMessageFilesResponse extends NearbyMessageFilesContent {
  ///
  /// Used to send a response to a previously received request.
  /// Provide [id] and [files] from [NearbyMessageFilesRequest] or
  /// Use the [NearbyMessageFilesResponse.fromRequest] factory to generate a
  /// response.
  ///
  NearbyMessageFilesResponse({
    required super.id,
    required super.files,
    required this.response,
  }) : super(
          NearbyMessageContentType.filesResponse,
        );

  ///
  /// Factory to quickly create a response to [NearbyMessageFilesRequest].
  ///
  factory NearbyMessageFilesResponse.fromRequest(
    NearbyMessageFilesRequest request, {
    required bool response,
  }) {
    return NearbyMessageFilesResponse(
      id: request.id,
      files: request.files,
      response: response,
    );
  }

  ///
  /// Gets [NearbyMessageFilesResponse] from [Map]
  ///
  factory NearbyMessageFilesResponse.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFilesResponse(
      id: json?['id'] ?? '',
      files: [
        ...?(json?['files'] as List?)?.map(
          (e) => NearbyFileInfo.fromJson(e),
        ),
      ],
      response: json?['response'] ?? false,
    );
  }

  ///
  /// The main response to the received [NearbyMessageFilesRequest].
  ///
  final bool response;

  @override
  Map<String, dynamic> toJson() {
    return {
      'response': response,
      ...super.toJson(),
    };
  }

  @override
  String toString() {
    return 'NearbyMessageFileResponse{response: $response, id: $id, files: $files}';
  }
}
