import 'dart:async';

import 'package:flutter/foundation.dart';

class NearbyServiceListenable<T> {
  NearbyServiceListenable({required this.initialValue});

  final T initialValue;
  late final ValueNotifier<T> notifier = ValueNotifier<T>(initialValue);
  late final StreamController<T> _controller = StreamController<T>.broadcast()
    ..add(notifier.value);

  T get value => notifier.value;

  Stream<T> get broadcastStream => _controller.stream.asBroadcastStream();

  void add(T value) {
    notifier.value = value;
    _controller.add(value);
  }
}
