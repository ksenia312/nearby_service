import 'package:nearby_service/nearby_service.dart';

///
/// A representation of a file that can be got from the Nearby Service's
/// communication channel.
///
/// From the communication channel, you usually get
/// the [NearbyMessageFilesRequest] request first.
/// After that, you can send positive [NearbyMessageFilesResponse] and
/// get the list of [NearbyFileInfo].
///
class NearbyFileInfo {
  ///
  /// Contains the file [path] to get the file from it.
  ///
  const NearbyFileInfo({required this.path});

  factory NearbyFileInfo.fromJson(Map<String, dynamic>? json) {
    return NearbyFileInfo(
      path: json?['path'] ?? '',
    );
  }

  ///
  /// Path of the representing file
  ///
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyFileInfo &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'path': path,
    };
  }

  ///
  /// Quick access to the file [name]
  ///
  String get name {
    try {
      return path.split('/').last;
    } catch (e) {
      return path;
    }
  }

  ///
  /// Quick access to the file [extension]
  ///
  String get extension {
    try {
      return name.split('.').last;
    } catch (e) {
      throw NearbyServiceException('Can\'t get extension from $name');
    }
  }

  @override
  String toString() {
    return 'NearbyFileInfo{path: $path}';
  }
}
