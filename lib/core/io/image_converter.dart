import 'dart:typed_data';

import '../models/raw_face_image.dart';

class ImageConverter {
  const ImageConverter();

  RawFaceImage fromBytes({
    required Uint8List bytes,
    int? width,
    int? height,
    int rotation = 0,
  }) {
    return RawFaceImage(
      bytes: bytes,
      width: width,
      height: height,
      rotation: rotation,
    );
  }
}