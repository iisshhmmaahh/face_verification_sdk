import '../models/face_detection_result.dart';
import '../models/processed_face_image.dart';

abstract class IFaceCropper {
  Future<ProcessedFaceImage> cropFace(
    FaceDetectionResult detection,
  );
}