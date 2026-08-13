/// Represents the final state of face verification.
enum VerificationStatus {
  /// The face matched the enrolled identity.
  verified,

  /// A face was detected but did not match the enrolled identity.
  notVerified,
}

/// Final result returned by the face verification process.
class VerificationResult {
  const VerificationResult({
    required this.studentId,
    required this.status,
    required this.similarityScore,
    required this.threshold,
  });

  /// Student whose enrolled embedding was used.
  final String studentId;

  /// Final verification status.
  final VerificationStatus status;

  /// Cosine similarity between the enrolled and captured face.
  final double similarityScore;

  /// Similarity threshold used for the comparison.
  final double threshold;

  /// Whether verification succeeded.
  bool get isVerified =>
      status == VerificationStatus.verified;

  /// Backwards-compatible match property.
  bool get isMatch => isVerified;

  /// Backwards-compatible score property.
  double get score => similarityScore;
}