import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../../config/model_config.dart';
import '../../exceptions/face_exceptions.dart';
import '../../interfaces/i_onnx_runtime_service.dart';
import '../../logger/sdk_logger.dart';

class OnnxRuntimeService implements IOnnxRuntimeService {
  OnnxRuntimeService();

  OrtSession? _session;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    SdkLogger.info('ONNX: Initializing environment...');

    OrtEnv.instance.init();

    SdkLogger.info('ONNX: Environment initialized.');

    final sessionOptions = OrtSessionOptions();

    SdkLogger.info('ONNX: Loading model asset...');

    final rawModel = await rootBundle.load(
      ModelConfig.modelAsset,
    );

    SdkLogger.info(
      'ONNX: Model asset loaded '
      '(${rawModel.lengthInBytes} bytes).',
    );

    final modelBytes = rawModel.buffer.asUint8List();

    SdkLogger.info('ONNX: Creating session...');

    _session = OrtSession.fromBuffer(
      modelBytes,
      sessionOptions,
    );

    SdkLogger.info('ONNX: Session created.');

    _initialized = true;

    SdkLogger.info('ONNX: Initialization complete.');
  }

  @override
  Future<Float32List> run(
    Float32List input,
  ) async {
    SdkLogger.info('ONNX: run() started.');

    if (!_initialized || _session == null) {
      SdkLogger.error(
        'ONNX: Session is not initialized.',
      );

      throw const ModelNotLoadedException();
    }

    SdkLogger.info(
      'ONNX: Input tensor length = ${input.length}',
    );

    final expectedLength =
        ModelConfig.channels *
        ModelConfig.inputHeight *
        ModelConfig.inputWidth;

    if (input.length != expectedLength) {
      SdkLogger.error(
        'ONNX: Invalid input tensor length. '
        'Expected $expectedLength, got ${input.length}.',
      );

      throw const EmbeddingGenerationException();
    }

    final inputTensor =
        OrtValueTensor.createTensorWithDataList(
      input,
      [
        1,
        ModelConfig.channels,
        ModelConfig.inputHeight,
        ModelConfig.inputWidth,
      ],
    );

    SdkLogger.info('ONNX: Input tensor created.');

    try {
      SdkLogger.info(
        'ONNX: Starting session.runAsync()...',
      );

      final outputs = await _session!.runAsync(
        OrtRunOptions(),
        {
          'input.1': inputTensor,
        },
      );

      SdkLogger.info(
        'ONNX: session.runAsync() returned.',
      );

      if (outputs == null || outputs.isEmpty) {
        SdkLogger.error(
          'ONNX: No outputs returned.',
        );

        throw const EmbeddingGenerationException();
      }

      SdkLogger.info(
        'ONNX: Number of outputs = ${outputs.length}',
      );

      final firstOutput = outputs.first;

      if (firstOutput == null) {
        SdkLogger.error(
          'ONNX: First output is null.',
        );

        throw const EmbeddingGenerationException();
      }

      final outputValue = firstOutput.value;

      SdkLogger.info(
        'ONNX: Output value type = '
        '${outputValue.runtimeType}',
      );

      if (outputValue is! List) {
        SdkLogger.error(
          'ONNX: Unexpected output format.',
        );

        throw const EmbeddingGenerationException();
      }

      final flattenedOutput = <double>[];

      void collectValues(dynamic value) {
        if (value is List) {
          for (final item in value) {
            collectValues(item);
          }
        } else if (value is num) {
          flattenedOutput.add(
            value.toDouble(),
          );
        }
      }

      collectValues(outputValue);

      SdkLogger.info(
        'ONNX: Flattened output length = '
        '${flattenedOutput.length}',
      );

      if (flattenedOutput.length != 512) {
        SdkLogger.error(
          'ONNX: Invalid embedding dimension. '
          'Expected 512, got ${flattenedOutput.length}.',
        );

        throw const EmbeddingGenerationException();
      }

      SdkLogger.info(
        'ONNX: 512-dimensional embedding generated.',
      );

      return Float32List.fromList(
        flattenedOutput,
      );
    } finally {
      inputTensor.release();

      SdkLogger.info(
        'ONNX: Input tensor released.',
      );
    }
  }

  @override
  Future<void> dispose() async {
    if (!_initialized && _session == null) {
      return;
    }

    SdkLogger.info('ONNX: Disposing...');

    _session?.release();
    _session = null;

    _initialized = false;

    SdkLogger.info('ONNX: Disposed.');
  }
}