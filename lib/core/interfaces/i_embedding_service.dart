import '../models/face_detection_result.dart';

abstract class IEmbeddingService {
  Future<List<double>> generateEmbedding(
    FaceDetectionResult detection,
  );
}