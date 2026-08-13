import 'dart:math';

import '../../interfaces/i_embedding_service.dart';
import '../../interfaces/i_image_preprocessor_service.dart';
import '../../interfaces/i_onnx_runtime_service.dart';
import '../../models/face_detection_result.dart';

class ArcFaceService implements IEmbeddingService {
  const ArcFaceService({
    required IImagePreprocessorService preprocessor,
    required IOnnxRuntimeService runtime,
  })  : _preprocessor = preprocessor,
        _runtime = runtime;

  final IImagePreprocessorService _preprocessor;
  final IOnnxRuntimeService _runtime;

  @override
  Future<List<double>> generateEmbedding(
    FaceDetectionResult detection,
  ) async {
    
    final tensor = await _preprocessor.preprocess(
      detection,
    );

    
    await _runtime.initialize();

    
    final rawEmbedding = await _runtime.run(
      tensor,
    );

    if (rawEmbedding.isEmpty) {
      throw Exception(
        'ArcFace returned an empty embedding.',
      );
    }

    
    double sumOfSquares = 0.0;

    for (final value in rawEmbedding) {
      sumOfSquares += value * value;
    }

    final magnitude = sqrt(sumOfSquares);

    if (magnitude == 0.0) {
      throw Exception(
        'ArcFace embedding has zero magnitude.',
      );
    }

    final normalizedEmbedding = <double>[];

    for (final value in rawEmbedding) {
      normalizedEmbedding.add(
        value / magnitude,
      );
    }

    return normalizedEmbedding;
  }
}