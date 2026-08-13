import 'dart:typed_data';

abstract class IOnnxRuntimeService {
  Future<void> initialize();

  Future<Float32List> run(Float32List input);

  Future<void> dispose();
}