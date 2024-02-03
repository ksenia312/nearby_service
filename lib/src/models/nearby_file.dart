import 'dart:io';
import 'package:nearby_service/nearby_service.dart';

///
/// A representation of a file that can be got from the Nearby Service's
/// communication channel.
///
/// From the communication channel, you usually get
/// the [NearbyMessageFilesRequest] request first.
/// After that, you can send positive [NearbyMessageFilesResponse] and
/// get the list of [NearbyFile].
///
class NearbyFile {
  ///
  /// Pass [info] assigned to file to be sent.
  ///
  const NearbyFile({
    required this.info,
    required this.file,
  });

  ///
  /// Quick info about the file
  ///
  final NearbyFileInfo info;

  ///
  /// A file that you can save in your phone if needed
  ///
  final File file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyFile &&
          runtimeType == other.runtimeType &&
          info == other.info &&
          file == other.file;

  @override
  int get hashCode => info.hashCode ^ file.hashCode;

  @override
  String toString() {
    return 'NearbyFile{info: $info, file: $file}';
  }
}

///
/// Quick info about the file
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
