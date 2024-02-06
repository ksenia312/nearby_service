import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class IdleView extends StatefulWidget {
  const IdleView({super.key});

  @override
  State<IdleView> createState() => _IdleViewState();
}

class _IdleViewState extends State<IdleView> {
  late final controller = TextEditingController();
  bool initialized = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<AppService>().getSavedIOSDeviceName().then((value) {
        controller.text = value;
        controller.selection = TextSelection.collapsed(offset: value.length);
        setState(() {
          initialized = true;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Getting saved name...',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'Enter the name of your device',
                ),
                controller: controller,
              ),
            ),
          ActionButton(
            onTap: () {
              context.read<AppService>().initialize(controller.text);
            },
            title: 'Tap to start',
          ),
        ],
      ),
    );
  }
}
