import 'dart:async';

import 'package:flutter/foundation.dart';

class NearbyServiceStreamListener<T> {
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
