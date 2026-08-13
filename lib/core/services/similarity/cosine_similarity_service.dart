
import 'dart:math';

import '../../interfaces/i_similarity_service.dart';
import '../../models/face_embedding.dart';
import '../../models/verification_result.dart';

class CosineSimilarityService implements ISimilarityService {
  const CosineSimilarityService({
    this.threshold = 0.35,
  });

  final double threshold;

  @override
  Future<VerificationResult> compare({
    required FaceEmbedding enrolledEmbedding,
    required FaceEmbedding verificationEmbedding,
  }) async {
    if (enrolledEmbedding.vector.length !=
        verificationEmbedding.vector.length) {
      throw ArgumentError(
        'Embedding vectors must have the same length.',
      );
    }

    double dotProduct = 0;
    double enrolledMagnitude = 0;
    double verificationMagnitude = 0;

    for (int i = 0;
        i < enrolledEmbedding.vector.length;
        i++) {
      final enrolled = enrolledEmbedding.vector[i];
      final verification = verificationEmbedding.vector[i];

      dotProduct += enrolled * verification;
      enrolledMagnitude += enrolled * enrolled;
      verificationMagnitude += verification * verification;
    }

    enrolledMagnitude = sqrt(enrolledMagnitude);
    verificationMagnitude = sqrt(verificationMagnitude);

    if (enrolledMagnitude == 0 ||
        verificationMagnitude == 0) {
      throw ArgumentError(
        'Embedding vector magnitude cannot be zero.',
      );
    }

    final similarity =
        dotProduct /
        (enrolledMagnitude * verificationMagnitude);

    final match = similarity >= threshold;

    return VerificationResult(
      studentId: enrolledEmbedding.studentId,
      status: match
        ? VerificationStatus.verified
        : VerificationStatus.notVerified,
      similarityScore: similarity,
      threshold: threshold,
    );
  }
}
