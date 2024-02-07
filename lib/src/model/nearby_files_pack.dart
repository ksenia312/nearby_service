import 'package:nearby_service/nearby_service.dart';

///
/// Used to provide result [files] that was got from [sender].
///
/// Can be received from [NearbyServiceFilesListener] only.
///
class ReceivedNearbyFilesPack implements NearbyReceivedInterface {
  const ReceivedNearbyFilesPack({
    required this.id,
    required this.sender,
    required this.files,
  });

  factory ReceivedNearbyFilesPack.fromJson(Map<String, dynamic>? json) {
    return ReceivedNearbyFilesPack(
      id: json?['id'],
      sender: NearbyDeviceInfo.fromJson(json?['sender']),
      files: [
        ...?(json?['files'] as List?)?.map(
          (e) => NearbyFileInfo.fromJson(e as Map<String, dynamic>),
        ),
      ],
    );
  }

  @override
  final NearbyDeviceInfo sender;

  ///
  /// Received list of [NearbyFileInfo].
  ///
  final List<NearbyFileInfo> files;

  ///
  /// ID of the files pack
  ///
  final String id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'files': [
        ...files.map((e) => e.toJson()),
      ],
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceivedNearbyFilesPack &&
          runtimeType == other.runtimeType &&
          sender == other.sender &&
          files == other.files &&
          id == other.id;

  @override
  int get hashCode => sender.hashCode ^ files.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'ReceivedNearbyFilesPack{sender: $sender, files: $files, id: $id}';
  }
}
