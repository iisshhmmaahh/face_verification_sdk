import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'raw_face_image.dart';

/// Result returned after face detection.
class FaceDetectionResult {
  const FaceDetectionResult({
    required this.image,
    required this.face,
  });

  /// Original image.
  final RawFaceImage image;

  /// Face detected by ML Kit.
  final Face face;
}