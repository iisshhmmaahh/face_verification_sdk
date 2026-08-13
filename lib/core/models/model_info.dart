/// Describes the loaded ONNX model.
class ModelInfo {
  const ModelInfo({
    required this.name,
    required this.inputWidth,
    required this.inputHeight,
    required this.embeddingSize,
  });

  /// Model name.
  final String name;

  /// Expected input width.
  final int inputWidth;

  /// Expected input height.
  final int inputHeight;

  /// Embedding dimension.
  final int embeddingSize;
}