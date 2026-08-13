/// Configuration for the ArcFace ONNX model.
class ModelConfig {
  const ModelConfig._();

  /// ONNX model bundled with the SDK.
  static const String modelAsset =
      'packages/face_verification_sdk/assets/models/w600k_r50.onnx';

  /// ArcFace model input dimensions.
  static const int inputWidth = 112;
  static const int inputHeight = 112;

  /// Number of input channels: RGB.
  static const int channels = 3;
}