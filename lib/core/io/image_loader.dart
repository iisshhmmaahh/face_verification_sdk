import 'package:flutter/services.dart';

class ImageLoader {
  const ImageLoader();

  /// Load an image from Flutter assets.
  Future<Uint8List> loadAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }
}