import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/presentation/app.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:nearby_service_example_full/utils/files_saver.dart';
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
    return Selector<AppService, NearbyDevice?>(
      selector: (context, service) => service.connectedDevice,
      builder: (context, device, _) {
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
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: kGreenColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: FilesSaver.isImage(e.extension)
                                ? Image.file(
                                    File(e.path!),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenColor,
                                      ),
                                    ),
                                  ),
                        ),
                      );
                      if (FilesSaver.isImage(e.extension)) {
                        return Image.file(
                          File(e.path!),
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: kBlueColor),
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(
                            e.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kBlueColor,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
