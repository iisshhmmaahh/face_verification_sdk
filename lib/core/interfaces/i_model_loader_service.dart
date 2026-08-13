abstract class IModelLoaderService {
  Future<void> initialize();

  bool get isInitialized;
}