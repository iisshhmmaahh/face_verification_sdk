import 'package:flutter/services.dart';

import '../../core/exceptions/face_exceptions.dart';
import '../../core/models/raw_face_image.dart';

class LocalImageProvider {
  const LocalImageProvider();

  Future<RawFaceImage> loadStudentImage(
    String studentId,
  ) async {
    try {
      final ByteData data = await rootBundle.load(
        'packages/face_verification_sdk/assets/sample_data/$studentId.jpg',
      );

      final bytes = data.buffer.asUint8List();

      return RawFaceImage(
        bytes: bytes,
      );
    } catch (_) {
      throw StudentImageNotFoundException(studentId);
    }
  }
}