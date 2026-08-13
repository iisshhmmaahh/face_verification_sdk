import '../models/face_detection_result.dart';
import '../models/raw_face_image.dart';

abstract class IFaceDetectorService {
  Future<FaceDetectionResult> detectFace(
    RawFaceImage image,
  );
  Future<void> dispose();
}