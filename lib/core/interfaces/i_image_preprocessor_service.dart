import 'dart:typed_data';

import '../models/face_detection_result.dart';

abstract class IImagePreprocessorService {
  Future<Float32List> preprocess(
    FaceDetectionResult detection,
  );
}