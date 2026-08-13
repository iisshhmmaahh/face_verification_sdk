import '../models/face_embedding.dart';
import '../models/verification_result.dart';

abstract class ISimilarityService {
  Future<VerificationResult> compare({
    required FaceEmbedding enrolledEmbedding,
    required FaceEmbedding verificationEmbedding,
  });
}
