import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/random.dart';

///
/// Nearby message Text content.
///
/// Contains [value] - the message to be sent or received.
///
final class NearbyMessageTextContent extends NearbyMessageContentBase {
  const NearbyMessageTextContent({required this.value});

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
  NearbyMessageContentType get type => NearbyMessageContentType.text;

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
sealed class NearbyMessageFilesContent extends NearbyMessageContentBase {
  ///
  /// Here [type] = [NearbyMessageContentType.filesResponse] or
  /// [type] =  [NearbyMessageContentType.filesRequest]
  ///
  /// Also [NearbyMessageFilesContent] contains [id] of the files pack and
  /// list of [NearbyFileInfo] to determine the files.
  ///
  const NearbyMessageFilesContent({
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
final class NearbyMessageFilesRequest extends NearbyMessageFilesContent {
  const NearbyMessageFilesRequest._({
    required super.id,
    required super.files,
  });

  ///
  /// Basic constructor with [files] to be sent or received.
  ///
  NearbyMessageFilesRequest({required super.files})
      : super(
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
  NearbyMessageContentType get type => NearbyMessageContentType.filesRequest;

  @override
  String toString() {
    return 'NearbyMessageFileRequest{id: $id, files: $files}';
  }
}

///
/// Nearby message File Response. Used for file sending responses.
/// Does not contain files' bytes!
///
final class NearbyMessageFilesResponse extends NearbyMessageFilesContent {
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
  });

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
  NearbyMessageContentType get type => NearbyMessageContentType.filesResponse;

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
