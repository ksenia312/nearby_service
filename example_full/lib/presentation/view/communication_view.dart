import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/presentation/app.dart';
import 'package:nearby_service_example_full/presentation/components/file_preview.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

import '../components/device_preview.dart';

class CommunicationView extends StatefulWidget {
  const CommunicationView({super.key});

  @override
  State<CommunicationView> createState() => _CommunicationViewState();
}

class _CommunicationViewState extends State<CommunicationView> {
  String message = '';
  List<PlatformFile> files = [];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppService>();
    final filesLoadings = service.filesLoadings;
    final device = service.connectedDevice;
    if (device == null) {
      return Center(
        child: ActionButton(
          onTap: context.read<AppService>().stopListeningAll,
          title: 'Restart',
        ),
      );
    }
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: kGreenColor),
      borderRadius: BorderRadius.circular(32),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DevicePreview(device: device, largeView: true),
        const SizedBox(height: 10),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) => setState(() {
                    message = value;
                  }),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    enabledBorder: inputBorder,
                    border: inputBorder,
                    focusedBorder: inputBorder,
                    hintStyle: const TextStyle(color: kGreenColor),
                    hintText: 'Enter a message',
                  ),
                ),
              ),
              Flexible(
                child: ActionButton(
                  title: 'Send',
                  onTap: () => context.read<AppService>().sendTextRequest(
                        message,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text('OR'),
        const SizedBox(height: 10),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: ActionButton(
                  type: ActionType.success,
                  title: 'Choose files',
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                    );
                    setState(() {
                      files = [...?result?.files];
                    });
                  },
                ),
              ),
              Flexible(
                child: ActionButton(
                  title: 'Send',
                  onTap: () => context.read<AppService>().sendFilesRequest([
                    ...files
                        .map((e) => e.path)
                        .where((element) => element != null)
                        .cast<String>(),
                  ]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            ...filesLoadings.entries.map((entry) {
              return Text(
                'Files pack ${entry.key} with ${entry.value} files is loading.',
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Selected files:', style: TextStyle(fontSize: 18)),
        Flexible(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...files.where((element) => element.path != null).map(
                (e) {
                  return FilePreview(file: e);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
