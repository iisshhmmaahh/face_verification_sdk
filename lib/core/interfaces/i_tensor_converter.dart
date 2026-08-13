import 'dart:typed_data';

import 'package:image/image.dart' as img;

abstract class ITensorConverter {
  Float32List convert(img.Image image);
}