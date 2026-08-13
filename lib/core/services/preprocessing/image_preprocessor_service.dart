import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../interfaces/i_face_cropper.dart';
import '../../interfaces/i_image_normalizer.dart';
import '../../interfaces/i_image_preprocessor_service.dart';
import '../../interfaces/i_image_resizer.dart';
import '../../models/face_detection_result.dart';

class ImagePreprocessorService
    implements IImagePreprocessorService {
  const ImagePreprocessorService({
    required IFaceCropper faceCropper,
    required IImageResizer imageResizer,
    required IImageNormalizer imageNormalizer,
  })  : _faceCropper = faceCropper,
        _imageResizer = imageResizer,
        _imageNormalizer = imageNormalizer;

  final IFaceCropper _faceCropper;
  final IImageResizer _imageResizer;
  final IImageNormalizer _imageNormalizer;

  @override
  Future<Float32List> preprocess(
    FaceDetectionResult detection,
  ) async {
    final cropped =
        await _faceCropper.cropFace(detection);

    final decoded =
        img.decodeImage(cropped.bytes);

    if (decoded == null) {
      throw Exception(
        'Failed to decode cropped image.',
      );
    }

    final resized =
        _imageResizer.resize(decoded);

    return _imageNormalizer.normalize(
      resized,
    );
  }
}