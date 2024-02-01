import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service/src/utils/random.dart';

///
/// Type of the message.
///
/// If [text], it will be a text message.
/// If [file], it will be a file request. After accepting request,
/// user can get file stream from connected device.
///
enum NearbyMessageContentType {
  text,
  file;

  ///
  /// Checks if this is [NearbyMessageContentType.text]
  ///
  bool get isText {
    return this == NearbyMessageContentType.text;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.file]
  ///
  bool get isFile {
    return this == NearbyMessageContentType.file;
  }
}

///
/// Abstraction for the message content.
/// Contains [_type] to determine, what type of content is it.
///
abstract class NearbyMessageContent {
  const NearbyMessageContent(this._type);

  ///
  /// Contains the conditional logic of creating [NearbyMessageFileContent]
  /// or [NearbyMessageTextContent] by `type` field of [json].
  ///
  factory NearbyMessageContent.fromJson(Map<String, dynamic>? json) {
    try {
      final type = NearbyMessageContentType.values.firstWhere(
        (e) => e.name == json?['type'],
      );
      if (type.isFile) {
        return NearbyMessageFileContent.fromJson(json);
      } else if (type.isText) {
        return NearbyMessageTextContent.fromJson(json);
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
  /// * The [onFile] callback returns this instance of [NearbyMessageContent],
  /// cast as [NearbyMessageFileContent] if is a file.
  ///
  T? get<T>({
    T Function(NearbyMessageTextContent)? onText,
    T Function(NearbyMessageFileContent)? onFile,
  }) {
    if (this is NearbyMessageTextContent && onText != null) {
      return onText(this as NearbyMessageTextContent);
    } else if (this is NearbyMessageFileContent && onFile != null) {
      return onFile(this as NearbyMessageFileContent);
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
/// Nearby message File content. Used for file sending requests.
/// Does not contain file bytes!
///
/// Contains [filePath] - the name of file to be sent or received.
///
class NearbyMessageFileContent extends NearbyMessageContent {
  const NearbyMessageFileContent._({
    required this.id,
    required this.filePath,
  }) : super(
          NearbyMessageContentType.file,
        );

  ///
  /// Basic constructor with [filePath] to be sent or received.
  ///
  NearbyMessageFileContent({required this.filePath})
      : id = RandomUtils.instance.nextInt(1000000, 9999999).toString(),
        super(
          NearbyMessageContentType.file,
        );

  ///
  /// Gets [NearbyMessageFileContent] from [json].
  ///
  factory NearbyMessageFileContent.fromJson(Map<String, dynamic>? json) {
    return NearbyMessageFileContent._(
      id: json?['id'] ?? '',
      filePath: json?['filePath'] ?? '',
    );
  }

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
  bool get isValid => filePath.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMessageFileContent &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath;

  @override
  int get hashCode => filePath.hashCode;

  @override
  String toString() {
    return 'NearbyMessageFileContent{filePath: $filePath, id: $id}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      ...super.toJson(),
    };
  }
}
