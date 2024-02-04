import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

///
/// Stream Subscription Listener.
///
class NearbyServiceSocketListener<T> {
  ///
  /// It is required to pass the [onData] parameter to process the
  /// data that came through the stream.
  ///
  const NearbyServiceSocketListener({
    required this.onData,
    this.onCreated,
    this.onDone,
    this.onError,
    this.cancelOnError,
  });

  final ValueChanged<T> onData;
  final VoidCallback? onCreated;
  final VoidCallback? onDone;
  final void Function(Object, [StackTrace])? onError;
  final bool? cancelOnError;
}

///
/// Stream Subscription Listener.
///
class NearbyServiceMessagesListener
    extends NearbyServiceSocketListener<ReceivedNearbyMessage> {
  ///
  /// It is required to pass the [onData] parameter to process the
  /// data that came through the stream.
  ///
  const NearbyServiceMessagesListener({
    required super.onData,
    super.onCreated,
    super.onDone,
    super.onError,
    super.cancelOnError,
  });
}

///
/// Stream Subscription Listener.
///
class NearbyServiceFilesListener
    extends NearbyServiceSocketListener<ReceivedNearbyFilesPack> {
  ///
  /// It is required to pass the [onData] parameter to process the
  /// data that came through the stream.
  ///
  const NearbyServiceFilesListener({
    required super.onData,
    super.onCreated,
    super.onDone,
    super.onError,
    super.cancelOnError,
  });
}
