import 'dart:convert';

import 'package:nearby_service/nearby_service.dart';

class JSONDecoder {
  JSONDecoder._();

  static Map<String, dynamic>? decodeMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return jsonDecode(value) as Map<String, dynamic>;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw NearbyServiceException.unsupportedDecoding(value);
  }

  static List? decodeList(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return jsonDecode(value) as List?;
    }
    if (value is List) {
      return value;
    }
    throw NearbyServiceException.unsupportedDecoding(value);
  }
}
