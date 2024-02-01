import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nearby_service/nearby_service.dart';

///
/// Stream Subscription Listener.
///
class NearbyServiceStreamListener {
  ///
  /// It is required to pass the [onData] parameter to process the
  /// data that came through the stream.
  ///
  const NearbyServiceStreamListener({
    required this.onData,
    this.onCreated,
    this.onDone,
    this.onError,
    this.cancelOnError,
  });

  final ValueChanged<ReceivedNearbyMessage> onData;
  final ValueChanged<StreamSubscription<ReceivedNearbyMessage>>? onCreated;
  final VoidCallback? onDone;
  final void Function(Object, [StackTrace])? onError;
  final bool? cancelOnError;
}
