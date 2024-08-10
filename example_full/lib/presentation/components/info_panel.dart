import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/presentation/app.dart';
import 'package:nearby_service_example_full/utils/extensions.dart';
import 'package:provider/provider.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  static Future show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: kWhiteColor,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informational panel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              AdditionalInfoPanel(),
              SizedBox(height: 8),
              InfoPanel(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, service, _) {
        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 8,
          children: [
            if (service.currentDeviceInfo != null)
              _InfoChip(
                label: 'Device P2P Name',
                value: service.currentDeviceInfo!.displayName,
              ),
            _InfoChip(
              label: 'Communication channel state',
              value: service.communicationChannelState.previewName,
            ),
            if (Platform.isIOS)
              _InfoChip(
                label: 'Role',
                value: service.isIOSBrowser
                    ? 'You are going to find your friend'
                    : 'You are waiting for another user to connect',
              ),
            if (Platform.isAndroid && service.isAndroidGroupOwner != null)
              _InfoChip(
                label: 'Role',
                value: service.isAndroidGroupOwner!
                    ? 'You are a group owner'
                    : 'You are not a group owner',
              ),
          ],
        );
      },
    );
  }
}

class AdditionalInfoPanel extends StatelessWidget {
  const AdditionalInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, service, _) {
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: [
          _InfoChip(
            label: 'Platform',
            value: service.platformVersion,
          ),
          _InfoChip(
            label: 'Model',
            value: service.platformModel,
          ),
          if (service.currentDeviceInfo != null && Platform.isIOS)
            _InfoChip(
              label: 'Device P2P ID',
              value: service.currentDeviceInfo!.id,
            ),
        ],
      );
    });
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Theme.of(context).shadowColor.withOpacity(0.4),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
