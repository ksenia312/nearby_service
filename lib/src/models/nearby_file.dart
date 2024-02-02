import 'dart:io';
import 'package:nearby_service/nearby_service.dart';

///
/// A representation of a file that can be got from the Nearby Service's
/// communication channel.
///
/// You can use [id] to compare it to the id from [NearbyMessageFileRequest.id].
///
/// From the communication channel, you usually get
/// the [NearbyMessageFileRequest] request first. After that, you get [NearbyFile].
///
class NearbyFile {
  ///
  /// Pass [content] assigned to file to be sent.
  ///
  const NearbyFile({
    required this.content,
    required this.file,
  });

  ///
  /// Quick info about the file
  ///
  final NearbyMessageFileContent content;

  ///
  /// A file that you can save in your phone if needed
  ///
  final File file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyFile &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          file == other.file;

  @override
  int get hashCode => content.hashCode ^ file.hashCode;

  @override
  String toString() {
    return 'NearbyFile{content: $content, file: $file}';
  }
}
