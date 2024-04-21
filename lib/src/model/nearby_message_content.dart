import 'package:nearby_service/nearby_service.dart';

///
/// Nearby message Text content.
///
/// Contains [value] - the message to be sent or received.
///
final class NearbyMessageTextRequest extends NearbyMessageContent {
  const NearbyMessageTextRequest.createManually({
    required this.value,
    required super.id,
  });

  NearbyMessageTextRequest.create({required this.value}) : super.create();

  ///
  /// Gets [NearbyMessageTextRequest] from [json]
  ///
  factory NearbyMessageTextRequest.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageTextRequest.createManually(
      id: json?['id'],
      value: json?['value'],
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
      other is NearbyMessageTextRequest &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'NearbyMessageTextRequest{id: $id, value: $value}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      ...super.toJson(),
    };
  }
}

final class NearbyMessageTextResponse extends NearbyMessageContent {
  const NearbyMessageTextResponse({required super.id});

  factory NearbyMessageTextResponse.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageTextResponse(id: json?['id']);
  }

  @override
  String toString() {
    return 'NearbyMessageTextResponse{id: $id}';
  }
}

///
/// Nearby message File Request. Used for files sending requests.
/// Contains info about the [files].
///
final class NearbyMessageFilesRequest extends NearbyMessageContent {
  ///
  /// Adds a [NearbyFileInfo] list to [id] to identify files.
  ///
  const NearbyMessageFilesRequest.createManually({
    required super.id,
    required this.files,
  });

  ///
  /// Basic constructor with [files] to be sent or received.
  /// Generates [id] in constructor.
  ///
  NearbyMessageFilesRequest.create({required this.files}) : super.create();

  ///
  /// Gets [NearbyMessageFilesRequest] from [json].
  ///
  factory NearbyMessageFilesRequest.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFilesRequest.createManually(
      id: json?['id'],
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
final class NearbyMessageFilesResponse extends NearbyMessageContent {
  ///
  /// Used to send a response to a previously received request.
  /// Provide [id] from [NearbyMessageFilesRequest].
  ///
  NearbyMessageFilesResponse({
    required super.id,
    required this.isAccepted,
  });

  ///
  /// Gets [NearbyMessageFilesResponse] from [Map]
  ///
  factory NearbyMessageFilesResponse.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFilesResponse(
      id: json?['id'] ?? '',
      isAccepted: json?['isAccepted'] ?? false,
    );
  }

  ///
  /// The main response to the received [NearbyMessageFilesRequest].
  ///
  final bool isAccepted;

  @override
  Map<String, dynamic> toJson() {
    return {
      'isAccepted': isAccepted,
      ...super.toJson(),
    };
  }

  @override
  String toString() {
    return 'NearbyMessageFileResponse{isAccepted: $isAccepted, id: $id}';
  }
}
