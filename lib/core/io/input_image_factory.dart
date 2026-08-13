import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:path_provider/path_provider.dart';

import '../models/raw_face_image.dart';

/// Converts SDK image models into ML Kit InputImage objects.
///
/// This class hides ML Kit specific conversion logic from the rest
/// of the SDK.
class InputImageFactory {
  const InputImageFactory();

  Future<InputImage> fromRawImage(
    RawFaceImage image,
  ) async {
    final file = await _createTemporaryImage(image.bytes);

    return InputImage.fromFilePath(file.path);
  }

  Future<File> _createTemporaryImage(
    Uint8List bytes,
  ) async {
    final directory = await getTemporaryDirectory();

    final file = File(
      '${directory.path}/face_sdk_temp.jpg',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }
}