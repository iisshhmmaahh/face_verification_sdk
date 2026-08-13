import '../../core/models/face_embedding.dart';
import '../../core/models/raw_face_image.dart';
import '../../core/models/verification_result.dart';
import '../../enrollment/interfaces/i_enrollment_service.dart';
import '../../verification/interfaces/i_verification_service.dart';

class FaceVerificationSdkImpl {
  const FaceVerificationSdkImpl({
    required IEnrollmentService enrollmentService,
    required IVerificationService verificationService,
  })  : _enrollmentService = enrollmentService,
        _verificationService = verificationService;

  final IEnrollmentService _enrollmentService;
  final IVerificationService _verificationService;

  Future<FaceEmbedding> enrollStudent({
    required String studentId,
  }) {
    return _enrollmentService.enrollStudent(
      studentId: studentId,
    );
  }

  Future<VerificationResult> verifyStudent({
    required FaceEmbedding enrolledEmbedding,
    required RawFaceImage verificationImage,
  }) {
    return _verificationService.verify(
      enrolledEmbedding: enrolledEmbedding,
      verificationImage: verificationImage,
    );
  }
}