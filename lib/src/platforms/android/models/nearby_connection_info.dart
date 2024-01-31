import 'dart:convert';

class NearbyConnectionAndroidInfo {
  static const unknown = 'unknown';

  const NearbyConnectionAndroidInfo({
    required this.ownerIpAddress,
    required this.groupFormed,
    required this.isGroupOwner,
  });

  factory NearbyConnectionAndroidInfo.fromJson(Map<String, dynamic> json) {
    final ownerIpAddress = (json['groupOwnerAddress'] ?? unknown) as String;
    return NearbyConnectionAndroidInfo(
      ownerIpAddress: ownerIpAddress.replaceFirst('/', ''),
      groupFormed: json['groupFormed'] ?? false,
      isGroupOwner: json['isGroupOwner'] ?? false,
    );
  }

  final String ownerIpAddress;
  final bool isGroupOwner;
  final bool groupFormed;
}

class NearbyConnectionInfoMapper {
  NearbyConnectionInfoMapper._();

  static NearbyConnectionAndroidInfo? mapToInfo(dynamic value) {
    final jsonValue = jsonDecode(value) as Map<String, dynamic>?;
    if (jsonValue == null) {
      return null;
    }
    return NearbyConnectionAndroidInfo.fromJson(jsonValue);
  }
}
