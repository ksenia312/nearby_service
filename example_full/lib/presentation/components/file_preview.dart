import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/presentation/app.dart';
import 'package:nearby_service_example_full/utils/files_saver.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.file});

  final PlatformFile file;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: kGreenColor,
          width: 2,
          strokeAlign: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FilesSaver.isImage(file.extension)
            ? Image.file(
                File(file.path!),
                fit: BoxFit.cover,
              )
            : Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: kGreenColor,
                  ),
                ),
              ),
      ),
    );
  }
}
