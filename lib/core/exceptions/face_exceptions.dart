
/// Base exception for the Face Verification SDK.
abstract class FaceVerificationException implements Exception {
  const FaceVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// SDK was used before initialize().
class SdkNotInitializedException extends FaceVerificationException {
  const SdkNotInitializedException()
      : super(
          'Face Verification SDK has not been initialized. '
          'Call initialize() before using the SDK.',
        );
}

/// No face was detected in the supplied image.
class FaceNotFoundException extends FaceVerificationException {
  const FaceNotFoundException()
      : super(
          'No face was detected in the image.',
        );
}

/// More than one face was detected.
class MultipleFacesDetectedException extends FaceVerificationException {
  const MultipleFacesDetectedException()
      : super(
          'Multiple faces were detected. '
          'Only one face is allowed.',
        );
}

/// The supplied image could not be processed.
class InvalidImageException extends FaceVerificationException {
  const InvalidImageException([
    String message =
        'The supplied image is invalid or could not be processed.',
  ]) : super(message);
}

/// The ArcFace ONNX model could not be loaded.
class ModelNotLoadedException extends FaceVerificationException {
  const ModelNotLoadedException()
      : super(
          'The face recognition model has not been loaded.',
        );
}

/// Face embedding generation failed.
class EmbeddingGenerationException extends FaceVerificationException {
  const EmbeddingGenerationException([
    String message = 'Unable to generate a face embedding.',
  ]) : super(message);
}

/// Student image could not be found.
class StudentImageNotFoundException extends FaceVerificationException {
  const StudentImageNotFoundException(
    String studentId,
  ) : super(
          'No enrolled image was found for student: $studentId',
        );
}

/// Verification could not be completed.
class VerificationFailedException extends FaceVerificationException {
  const VerificationFailedException([
    String message =
        'Face verification could not be completed.',
  ]) : super(message);
}
