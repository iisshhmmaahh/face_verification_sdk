import '../../company/providers/local_image_provider.dart';
import '../../core/interfaces/i_embedding_service.dart';
import '../../core/interfaces/i_face_detector_service.dart';
import '../../core/models/face_embedding.dart';
import '../interfaces/i_enrollment_service.dart';

class EnrollmentService implements IEnrollmentService {
  const EnrollmentService({
    required LocalImageProvider imageProvider,
    required IFaceDetectorService faceDetector,
    required IEmbeddingService embeddingService,
  })  : _imageProvider = imageProvider,
        _faceDetector = faceDetector,
        _embeddingService = embeddingService;

  final LocalImageProvider _imageProvider;
  final IFaceDetectorService _faceDetector;
  final IEmbeddingService _embeddingService;

  @override
  Future<FaceEmbedding> enrollStudent({
    required String studentId,
  }) async {
    final rawImage =
        await _imageProvider.loadStudentImage(
      studentId,
    );

    final detection =
        await _faceDetector.detectFace(
      rawImage,
    );

    final embedding =
        await _embeddingService.generateEmbedding(
      detection,
    );

    return FaceEmbedding(
      studentId: studentId,
      vector: embedding,
      generatedAt: DateTime.now(),
    );
  }
}