import '../../core/interfaces/i_embedding_service.dart';
import '../../core/interfaces/i_face_detector_service.dart';
import '../../core/interfaces/i_similarity_service.dart';
import '../../core/models/face_embedding.dart';
import '../../core/models/raw_face_image.dart';
import '../../core/models/verification_result.dart';
import '../interfaces/i_verification_service.dart';

class VerificationService implements IVerificationService {
  const VerificationService({
    required IFaceDetectorService faceDetector,
    required IEmbeddingService embeddingService,
    required ISimilarityService similarityService,
  })  : _faceDetector = faceDetector,
        _embeddingService = embeddingService,
        _similarityService = similarityService;

  final IFaceDetectorService _faceDetector;
  final IEmbeddingService _embeddingService;
  final ISimilarityService _similarityService;

  @override
  Future<VerificationResult> verify({
    required FaceEmbedding enrolledEmbedding,
    required RawFaceImage verificationImage,
  }) async {
    final detection =
        await _faceDetector.detectFace(
      verificationImage,
    );

    final verificationVector =
        await _embeddingService.generateEmbedding(
      detection,
    );

    final verificationEmbedding =
        FaceEmbedding(
      studentId: enrolledEmbedding.studentId,
      vector: verificationVector,
      generatedAt: DateTime.now(),
    );

    return _similarityService.compare(
      enrolledEmbedding: enrolledEmbedding,
      verificationEmbedding: verificationEmbedding,
    );
  }
}