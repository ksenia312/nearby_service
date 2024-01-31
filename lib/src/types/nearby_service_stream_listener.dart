import 'dart:async';

import 'package:flutter/foundation.dart';

///
/// Stream Subscription Listener.
///
class NearbyServiceStreamListener<T> {
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

  final ValueChanged<T> onData;
  final ValueChanged<StreamSubscription<T>>? onCreated;
  final VoidCallback? onDone;
  final void Function(Object, [StackTrace])? onError;
  final bool? cancelOnError;
}
