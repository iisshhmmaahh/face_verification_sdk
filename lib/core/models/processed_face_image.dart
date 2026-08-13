import 'dart:typed_data';
/// Represents a face after preprocessing,
/// ready for ArcFace inference.
class ProcessedFaceImage {
  const ProcessedFaceImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  /// Processed image bytes.
  final Uint8List bytes;

  /// Image width.
  final int width;

  /// Image height.
  final int height;
}