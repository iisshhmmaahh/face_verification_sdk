/// Face Verification SDK Constants
///
/// This class contains all the constant values used throughout
/// the SDK. Keeping them in one place makes maintenance easier.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  /// SDK Information
  static const String sdkName = 'Face Verification SDK';
  static const String sdkVersion = '1.0.0';

  /// ArcFace Model Information
  static const int embeddingDimension = 512;
  static const int modelInputSize = 112;

  /// Assets
  static const String modelAssetPath =
      'assets/models/arcface.onnx';

  /// Default Verification Threshold
  static const double similarityThreshold = 0.65;

  /// Camera
  static const int maxFacesAllowed = 1;
}