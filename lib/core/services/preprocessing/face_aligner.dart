import 'dart:math' as math;
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceAligner {
  const FaceAligner();

  Uint8List align({
    required img.Image image,
    required Face face,
  }) {
    final leftEye =
        face.landmarks[FaceLandmarkType.leftEye];

    final rightEye =
        face.landmarks[FaceLandmarkType.rightEye];

    // If ML Kit could not provide both eyes,
    // keep the original image.
    if (leftEye == null || rightEye == null) {
      return Uint8List.fromList(
        img.encodeJpg(image, quality: 95),
      );
    }

    final left = leftEye.position;
    final right = rightEye.position;

    final dx = right.x - left.x;
    final dy = right.y - left.y;

    final angle =
        math.atan2(dy, dx) * 180 / math.pi;

    // No need to rotate an almost-horizontal face.
    if (angle.abs() < 2.0) {
      return Uint8List.fromList(
        img.encodeJpg(image, quality: 95),
      );
    }

    final aligned = img.copyRotate(
      image,
      angle: -angle,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(
      img.encodeJpg(aligned, quality: 95),
    );
  }
}