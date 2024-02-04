///
/// Type of the message.
///
/// If [text], it will be a text message.
/// If [filesRequest], it will be a files pack request.
/// After accepting the request,
/// user can get files bytes stream from the connected device.
///
enum NearbyMessageContentType {
  text,
  filesRequest,
  filesResponse;

  ///
  /// Checks if this is [NearbyMessageContentType.text]
  ///
  bool get isText {
    return this == NearbyMessageContentType.text;
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
