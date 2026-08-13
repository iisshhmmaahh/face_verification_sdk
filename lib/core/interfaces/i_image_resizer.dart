import 'package:image/image.dart' as img;

abstract class IImageResizer {
  img.Image resize(img.Image image);
}