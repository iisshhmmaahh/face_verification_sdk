import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../config/face_detection_config.dart';
import '../../exceptions/face_exceptions.dart';
import '../../interfaces/i_face_detector_service.dart';
import '../../io/input_image_factory.dart';
import '../../models/face_detection_result.dart';
import '../../models/raw_face_image.dart';

class FaceDetectorService implements IFaceDetectorService {
  FaceDetectorService({
    InputImageFactory? inputImageFactory,
  })  : _inputImageFactory = inputImageFactory ?? const InputImageFactory(),
        _faceDetector = FaceDetector(
          options: FaceDetectionConfig.options,
        );

  final InputImageFactory _inputImageFactory;

  final FaceDetector _faceDetector;

  @override
  Future<FaceDetectionResult> detectFace(
    RawFaceImage image,
  ) async {
    final inputImage =
        await _inputImageFactory.fromRawImage(image);

    final faces =
        await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      throw const FaceNotFoundException();
    }

    if (faces.length > 1) {
      throw const MultipleFacesDetectedException();
    }

    return FaceDetectionResult(
      image: image,
      face: faces.first,
    );
  }

  @override
  Future<void> dispose() async {
    await _faceDetector.close();
  }
}