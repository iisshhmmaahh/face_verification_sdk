import '../../core/models/face_embedding.dart';
import '../../core/models/raw_face_image.dart';
import '../../core/models/verification_result.dart';

abstract class IVerificationService {
  Future<VerificationResult> verify({
    required FaceEmbedding enrolledEmbedding,
    required RawFaceImage verificationImage,
  });
}