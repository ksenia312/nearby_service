import 'package:nearby_service/nearby_service.dart';

///
/// Used to provide result [files] that was got from [sender].
///
/// Can be received from [NearbyServiceFilesListener] only.
///
class ReceivedNearbyFilesPack implements NearbyReceivedInterface {
  const ReceivedNearbyFilesPack({
    required this.sender,
    required this.files,
  });

  factory ReceivedNearbyFilesPack.fromJson(Map<String, dynamic>? json) {
    return ReceivedNearbyFilesPack(
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

  final List<NearbyFileInfo> files;

  Map<String, dynamic> toJson() {
    return {
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
          files == other.files;

  @override
  int get hashCode => sender.hashCode ^ files.hashCode;

  @override
  String toString() {
    return 'NearbyFilesPack{sender: $sender, files: $files}';
  }
}
