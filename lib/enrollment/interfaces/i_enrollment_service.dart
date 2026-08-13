import '../../core/models/face_embedding.dart';

abstract class IEnrollmentService {
  Future<FaceEmbedding> enrollStudent({
    required String studentId,
  });
}