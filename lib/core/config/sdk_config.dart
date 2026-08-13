import '../constants/app_constants.dart';

class SdkConfig {
  const SdkConfig({
    this.similarityThreshold = AppConstants.similarityThreshold,
    this.modelAssetPath = AppConstants.modelAssetPath,
    this.enableLogging = true,
  });

  /// Cosine similarity threshold used during verification.
  final double similarityThreshold;

  /// Location of the ArcFace ONNX model.
  final String modelAssetPath;

  /// Enable or disable SDK logs.
  final bool enableLogging;
}