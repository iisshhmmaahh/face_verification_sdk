import 'dart:typed_data';

/// Represents an image entering the face verification pipeline.
///
/// This model is used by both:
/// - Enrollment (downloaded/student images)
/// - Verification (live camera images)
class RawFaceImage {
  const RawFaceImage({
    required this.bytes,
    this.width,
    this.height,
    this.rotation = 0,
  });

  /// Raw image bytes.
  final Uint8List bytes;

  /// Image width in pixels.
  ///
  /// Optional for enrollment images.
  final int? width;

  /// Image height in pixels.
  ///
  /// Optional for enrollment images.
  final int? height;

  /// Rotation in degrees.
  ///
  /// Camera images may require rotation correction.
  final int rotation;
}