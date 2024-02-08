import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

class FilesMessagingView extends StatefulWidget {
  const FilesMessagingView({super.key, required this.onSend});

  final ValueChanged<List<NearbyFileInfo>> onSend;

  @override
  State<FilesMessagingView> createState() => _FilesMessagingViewState();
}

class _FilesMessagingViewState extends State<FilesMessagingView> {
  List<PlatformFile> _pickedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
            );
            if (result != null) {
              setState(() => _pickedFiles = result.files);
            }
          },
          child: const Text('Pick the files'),
        ),
        ElevatedButton(
          onPressed: () => widget.onSend(
            _pickedFiles.map((e) => NearbyFileInfo(path: e.path!)).toList(),
          ),
          child: const Text('Send files'),
        ),
        const Text('Picked files:', style: TextStyle(fontSize: 16)),
        ..._pickedFiles.map((e) => Text(e.name)),
      ],
    );
  }
}
