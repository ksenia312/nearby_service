import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/random.dart';

///
/// Nearby message Text content.
///
/// Contains [value] - the message to be sent or received.
///
final class NearbyMessageTextContent extends NearbyMessageContent {
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
  /// Here type is [NearbyMessageContentType.filesResponse] or
  /// [NearbyMessageContentType.filesRequest]
  ///
  /// Also [NearbyMessageFilesContent] contains [id] of the files pack.
  ///
  const NearbyMessageFilesContent({required this.id});

  ///
  /// ID of this files pack
  ///
  final String id;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      ...super.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageFilesContent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NearbyMessageFilesContent{id: $id}';
  }

  @override
  bool get isValid => id.isNotEmpty;
}

///
/// Nearby message File Request. Used for files sending requests.
/// Contains info about the [files].
///
final class NearbyMessageFilesRequest extends NearbyMessageFilesContent {
  ///
  /// Adds a [NearbyFileInfo] list to [id] to identify files.
  ///
  const NearbyMessageFilesRequest._({
    required super.id,
    required this.files,
  });

  ///
  /// Basic constructor with [files] to be sent or received.
  /// Generates [id] in constructor.
  ///
  NearbyMessageFilesRequest.create({required this.files})
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

  ///
  /// Info about the files to be sent or received.
  ///
  final List<NearbyFileInfo> files;

  @override
  String toString() {
    return 'NearbyMessageFileRequest{id: $id, files: $files}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'files': [
        ...files.map((e) => e.toJson()),
      ],
      ...super.toJson(),
    };
  }

  @override
  bool get isValid =>
      super.isValid &&
      files.isNotEmpty &&
      files.every((element) => element.path.isNotEmpty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NearbyMessageFilesRequest &&
          runtimeType == other.runtimeType &&
          files == other.files;

  @override
  int get hashCode => super.hashCode ^ files.hashCode;
}

///
/// Nearby message File Response. Used for file sending responses.
///
final class NearbyMessageFilesResponse extends NearbyMessageFilesContent {
  ///
  /// Used to send a response to a previously received request.
  /// Provide [id] from [NearbyMessageFilesRequest].
  ///
  NearbyMessageFilesResponse({
    required super.id,
    required this.response,
  });

  ///
  /// Gets [NearbyMessageFilesResponse] from [Map]
  ///
  factory NearbyMessageFilesResponse.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFilesResponse(
      id: json?['id'] ?? '',
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
    return 'NearbyMessageFileResponse{response: $response, id: $id}';
  }
}
