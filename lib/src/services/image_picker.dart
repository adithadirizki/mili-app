import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickResult {
  final Uint8List? bytes;
  final String filename;
  final XFile file;

  const PickResult({this.bytes, required this.filename, required this.file});
}

Future<PickResult?> pickImage(
  ImageSource source, {
  bool cropper = true,
  List<CropAspectRatioPreset>? aspectRatio,
  String? cropperTitle,
  int? imageQuality = 70,
  double? maxHeight = 1920,
  double? maxWidth = 1920,
  bool lockAspectRatio = true,
}) async {
  final file = await ImagePicker().pickImage(
    imageQuality: imageQuality,
    maxHeight: maxHeight,
    maxWidth: maxWidth,
    source: source,
  );

  if (file != null) {
    if (cropper) {
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: file.path,
          aspectRatioPresets: aspectRatio ?? [],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: cropperTitle ?? 'Cropper',
            toolbarColor: Colors.lightBlueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: lockAspectRatio,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      return PickResult(
        bytes: await croppedFile?.readAsBytes(),
        filename: file.name,
        file: file,
      );
    } else {
      return PickResult(
        bytes: await file.readAsBytes(),
        filename: file.name,
        file: file,
      );
    }
  }

  return null;
}
