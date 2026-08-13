import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../interfaces/i_tensor_converter.dart';

class TensorConverter implements ITensorConverter {
  const TensorConverter();

  @override
  Float32List convert(img.Image image) {
    throw UnimplementedError();
  }
}