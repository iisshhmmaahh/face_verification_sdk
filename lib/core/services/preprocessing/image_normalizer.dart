import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../config/model_config.dart';
import '../../interfaces/i_image_normalizer.dart';

class ImageNormalizer implements IImageNormalizer {
  const ImageNormalizer();

  @override
  Float32List normalize(img.Image image) {
    final tensor = Float32List(
      ModelConfig.channels *
          ModelConfig.inputWidth *
          ModelConfig.inputHeight,
    );

    final channelSize =
        ModelConfig.inputWidth * ModelConfig.inputHeight;

    for (int y = 0; y < ModelConfig.inputHeight; y++) {
      for (int x = 0; x < ModelConfig.inputWidth; x++) {
        final pixel = image.getPixel(x, y);

        final index = y * ModelConfig.inputWidth + x;

        tensor[index] =
            (pixel.r.toDouble() - 127.5) / 128.0;

        tensor[channelSize + index] =
            (pixel.g.toDouble() - 127.5) / 128.0;

        tensor[(2 * channelSize) + index] =
            (pixel.b.toDouble() - 127.5) / 128.0;
      }
    }

    return tensor;
  }
}