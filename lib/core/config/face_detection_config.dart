import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionConfig {
  const FaceDetectionConfig._();

  static final options = FaceDetectorOptions(
    performanceMode: FaceDetectorMode.accurate,

    enableLandmarks: true,

    enableContours: false,

    enableClassification: false,

    enableTracking: false,

    minFaceSize: 0.15,
  );
}