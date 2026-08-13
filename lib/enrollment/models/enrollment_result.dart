import '../../core/models/face_embedding.dart';

class EnrollmentResult {
  const EnrollmentResult({
    required this.embedding,
  });

  final FaceEmbedding embedding;
}