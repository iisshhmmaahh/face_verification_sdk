import 'dart:math' as math;
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../interfaces/i_face_cropper.dart';
import '../../models/face_detection_result.dart';
import '../../models/processed_face_image.dart';

class FaceCropperService implements IFaceCropper {
  const FaceCropperService();

  @override
  Future<ProcessedFaceImage> cropFace(
    FaceDetectionResult detection,
  ) async {
    final decoded = img.decodeImage(
      detection.image.bytes,
    );

    if (decoded == null) {
      throw Exception(
        'Failed to decode image for face cropping.',
      );
    }

    final face = detection.face;

    final leftEye =
        face.landmarks[FaceLandmarkType.leftEye];

    final rightEye =
        face.landmarks[FaceLandmarkType.rightEye];

    /*
     * ---------------------------------------------------------
     * ORIGINAL FACE INFORMATION
     * ---------------------------------------------------------
     */

    final originalBox = face.boundingBox;

    final originalCenterX =
        (originalBox.left + originalBox.right) / 2;

    final originalCenterY =
        (originalBox.top + originalBox.bottom) / 2;

    /*
     * ---------------------------------------------------------
     * ROTATE FACE USING EYE LANDMARKS
     * ---------------------------------------------------------
     */

    img.Image workingImage = decoded;

    double rotationDegrees = 0.0;

    if (leftEye != null && rightEye != null) {
      final left = leftEye.position;
      final right = rightEye.position;

      final dx = right.x - left.x;
      final dy = right.y - left.y;

      final angleRadians =
          math.atan2(dy, dx);

      rotationDegrees =
          -angleRadians * 180 / math.pi;

      if (rotationDegrees.abs() > 2.0) {
        workingImage = img.copyRotate(
          decoded,
          angle: rotationDegrees,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    /*
     * ---------------------------------------------------------
     * FIND THE ROTATED FACE CENTER
     *
     * image package rotates around the image center.
     * We therefore transform the original face center
     * into the rotated coordinate system.
     * ---------------------------------------------------------
     */

    final imageCenterX =
        decoded.width / 2.0;

    final imageCenterY =
        decoded.height / 2.0;

    final radians =
        rotationDegrees * math.pi / 180.0;

    final translatedX =
        originalCenterX - imageCenterX;

    final translatedY =
        originalCenterY - imageCenterY;

    final rotatedCenterX =
        translatedX * math.cos(radians) -
            translatedY * math.sin(radians) +
        workingImage.width / 2.0;

    final rotatedCenterY =
        translatedX * math.sin(radians) +
            translatedY * math.cos(radians) +
        workingImage.height / 2.0;

    /*
     * ---------------------------------------------------------
     * CREATE PADDED SQUARE CROP
     * ---------------------------------------------------------
     *
     * More padding gives ArcFace some surrounding context
     * while keeping the face centered.
     */

    final faceWidth = originalBox.width;
    final faceHeight = originalBox.height;

    final cropSize =
        math.max(faceWidth, faceHeight) * 1.55;

    int left =
        (rotatedCenterX - cropSize / 2).round();

    int top =
        (rotatedCenterY - cropSize / 2).round();

    int right =
        (rotatedCenterX + cropSize / 2).round();

    int bottom =
        (rotatedCenterY + cropSize / 2).round();

    /*
     * ---------------------------------------------------------
     * CLAMP TO IMAGE
     * ---------------------------------------------------------
     */

    left = left.clamp(
      0,
      workingImage.width,
    );

    top = top.clamp(
      0,
      workingImage.height,
    );

    right = right.clamp(
      0,
      workingImage.width,
    );

    bottom = bottom.clamp(
      0,
      workingImage.height,
    );

    final cropWidth =
        right - left;

    final cropHeight =
        bottom - top;

    if (cropWidth <= 0 || cropHeight <= 0) {
      throw Exception(
        'Invalid face crop dimensions.',
      );
    }

    /*
     * ---------------------------------------------------------
     * CROP
     * ---------------------------------------------------------
     */

    final cropped = img.copyCrop(
      workingImage,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );

    /*
     * ---------------------------------------------------------
     * RETURN JPEG
     * ---------------------------------------------------------
     */

    final bytes = Uint8List.fromList(
      img.encodeJpg(
        cropped,
        quality: 95,
      ),
    );

    return ProcessedFaceImage(
      bytes: bytes,
      width: cropped.width,
      height: cropped.height,
    );
  }
}