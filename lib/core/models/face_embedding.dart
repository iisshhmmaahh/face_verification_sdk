/// Represents a generated face embedding.
class FaceEmbedding {
  const FaceEmbedding({
    required this.studentId,
    required this.vector,
    required this.generatedAt,
  });

  /// Student identifier.
  final String studentId;

  /// 512-dimensional embedding vector.
  final List<double> vector;
  int get length => vector.length;

  /// Generation timestamp.
  final DateTime generatedAt;
}
