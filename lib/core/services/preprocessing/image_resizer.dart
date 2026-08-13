import 'package:image/image.dart' as img;

import '../../config/model_config.dart';
import '../../interfaces/i_image_resizer.dart';

class ImageResizer implements IImageResizer {
  const ImageResizer();

  @override
  img.Image resize(img.Image image) {
    return img.copyResize(
      image,
      width: ModelConfig.inputWidth,
      height: ModelConfig.inputHeight,
      interpolation: img.Interpolation.linear,
    );
  }
}