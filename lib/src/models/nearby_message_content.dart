import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/random.dart';

///
/// Type of the message.
///
/// If [text], it will be a text message.
/// If [fileRequest], it will be a file request. After accepting request,
/// user can get file stream from connected device.
///
enum NearbyMessageContentType {
  text,
  fileRequest,
  fileResponse;

  ///
  /// Checks if this is [NearbyMessageContentType.text]
  ///
  bool get isText {
    return this == NearbyMessageContentType.text;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.fileRequest]
  ///
  bool get isFileRequest {
    return this == NearbyMessageContentType.fileRequest;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.fileResponse]
  ///
  bool get isFileResponse {
    return this == NearbyMessageContentType.fileResponse;
  }
}

///
/// Abstraction for the message content.
/// Contains [_type] to determine, what type of content is it.
///
abstract class NearbyMessageContent {
  const NearbyMessageContent(this._type);

  ///
  /// Contains the conditional logic of creating [NearbyMessageFileRequest]
  /// or [NearbyMessageTextContent] by `type` field of [json].
  ///
  factory NearbyMessageContent.fromJson(Map<String, dynamic>? json) {
    try {
      final type = NearbyMessageContentType.values.firstWhere(
        (e) => e.name == json?['type'],
      );
      if (type.isFileRequest) {
        return NearbyMessageFileRequest.fromJson(json);
      } else if (type.isText) {
        return NearbyMessageTextContent.fromJson(json);
      } else if (type.isFileResponse) {
        return NearbyMessageFileResponse.fromJson(json);
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
  /// * The [onFileRequest] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageFileRequest] if is a file request.
  ///
  /// * The [onFileResponse] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageFileResponse] if is a file response.
  ///
  T? byType<T>({
    T Function(NearbyMessageTextContent)? onText,
    T Function(NearbyMessageFileRequest)? onFileRequest,
    T Function(NearbyMessageFileResponse)? onFileResponse,
  }) {
    if (this is NearbyMessageTextContent && onText != null) {
      return onText(this as NearbyMessageTextContent);
    } else if (this is NearbyMessageFileRequest && onFileRequest != null) {
      return onFileRequest(this as NearbyMessageFileRequest);
    } else if (this is NearbyMessageFileResponse && onFileResponse != null) {
      return onFileResponse(this as NearbyMessageFileResponse);
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

abstract class NearbyMessageFileContent extends NearbyMessageContent {
  const NearbyMessageFileContent(
    super.type, {
    required this.id,
    required this.filePath,
  });

  ///
  /// ID for comparing file requests.
  ///
  final String id;

  ///
  /// The name of the file to be sent or received.
  ///
  final String filePath;

  String get fileName {
    try {
      return filePath.split('/').last;
    } catch (e) {
      throw NearbyServiceException('Can\'t get fileName from $filePath');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageFileContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          filePath == other.filePath;

  @override
  int get hashCode => id.hashCode ^ filePath.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      ...super.toJson(),
    };
  }
}

///
/// Nearby message File content. Used for file sending requests.
/// Does not contain file bytes!
///
/// Contains [filePath] - the name of file to be sent or received.
///
class NearbyMessageFileRequest extends NearbyMessageFileContent {
  const NearbyMessageFileRequest._({
    required super.id,
    required super.filePath,
  }) : super(
          NearbyMessageContentType.fileRequest,
        );

  ///
  /// Basic constructor with [filePath] to be sent or received.
  ///
  NearbyMessageFileRequest({required super.filePath})
      : super(
          NearbyMessageContentType.fileRequest,
          id: RandomUtils.instance.nextInt(1000000, 9999999).toString(),
        );

  ///
  /// Gets [NearbyMessageFileRequest] from [json].
  ///
  factory NearbyMessageFileRequest.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFileRequest._(
      id: json?['id'] ?? '',
      filePath: json?['filePath'] ?? '',
    );
  }

  @override
  bool get isValid => filePath.isNotEmpty;

  @override
  String toString() {
    return 'NearbyMessageFileRequest{id: $id, filePath: $filePath}';
  }
}

class NearbyMessageFileResponse extends NearbyMessageFileContent {
  NearbyMessageFileResponse({
    required super.id,
    required super.filePath,
    required this.response,
  }) : super(
          NearbyMessageContentType.fileResponse,
        );

  factory NearbyMessageFileResponse.fromRequest(
    NearbyMessageFileRequest request, {
    required bool response,
  }) {
    return NearbyMessageFileResponse(
      id: request.id,
      filePath: request.filePath,
      response: response,
    );
  }

  factory NearbyMessageFileResponse.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFileResponse(
      id: json?['id'] ?? '',
      filePath: json?['filePath'] ?? '',
      response: json?['response'] ?? false,
    );
  }

  final bool response;

  @override
  bool get isValid => filePath.isNotEmpty;

  @override
  Map<String, dynamic> toJson() {
    return {
      'response': response,
      ...super.toJson(),
    };
  }

  @override
  String toString() {
    return 'NearbyMessageFileResponse{response: $response, id: $id, filePath: $filePath}';
  }
}
