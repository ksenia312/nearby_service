///
/// Type of the message.
///
/// If [textRequest], it will be a text message.
/// If [filesRequest], it will be a files pack request.
/// After accepting the request,
/// user can get files bytes stream from the connected device.
///
enum NearbyMessageContentType {
  textRequest,
  textResponse,
  filesRequest,
  filesResponse;

  ///
  /// Checks if this is [NearbyMessageContentType.textRequest]
  ///
  bool get isTextRequest {
    return this == NearbyMessageContentType.textRequest;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.textResponse]
  ///
  bool get isTextResponse {
    return this == NearbyMessageContentType.textResponse;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.filesRequest]
  ///
  bool get isFilesRequest {
    return this == NearbyMessageContentType.filesRequest;
  }

  ///
  /// Checks if this is [NearbyMessageContentType.filesResponse]
  ///
  bool get isFilesResponse {
    return this == NearbyMessageContentType.filesResponse;
  }
}
