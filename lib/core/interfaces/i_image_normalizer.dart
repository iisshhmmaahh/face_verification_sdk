import 'dart:typed_data';

import 'package:image/image.dart' as img;

abstract class IImageNormalizer {
  Float32List normalize(img.Image image);
}