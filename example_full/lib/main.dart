import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = AppService();
  await service.getPlatformInfo();

  runApp(
    App(service: service),
  );
}
