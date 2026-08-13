import 'core/interfaces/i_embedding_service.dart';
import 'core/interfaces/i_face_detector_service.dart';
import 'core/interfaces/i_image_preprocessor_service.dart';
import 'core/interfaces/i_onnx_runtime_service.dart';
import 'core/interfaces/i_similarity_service.dart';

import 'core/services/detection/face_detector_service.dart';
import 'core/services/inference/arcface_service.dart';
import 'core/services/inference/onnx_runtime_service.dart';
import 'core/services/preprocessing/face_cropper.dart';
import 'core/services/preprocessing/image_normalizer.dart';
import 'core/services/preprocessing/image_preprocessor_service.dart';
import 'core/services/preprocessing/image_resizer.dart';
import 'core/services/similarity/cosine_similarity_service.dart';

import 'core/exceptions/face_exceptions.dart';
import 'core/models/face_embedding.dart';
import 'core/models/raw_face_image.dart';
import 'core/models/verification_result.dart';

import 'company/providers/local_image_provider.dart';

import 'enrollment/interfaces/i_enrollment_service.dart';
import 'enrollment/services/enrollment_service.dart';

import 'verification/interfaces/i_verification_service.dart';
import 'verification/services/verification_service.dart';

export 'core/models/face_embedding.dart';
export 'core/models/raw_face_image.dart';
export 'core/models/verification_result.dart';

// ============================================================
// PUBLIC EXCEPTIONS
// ============================================================

export 'core/exceptions/face_exceptions.dart';

/// Public entry point for the Face Verification SDK.
///
/// The company application interacts with this class.
/// Internal services such as ML Kit, ArcFace and ONNX Runtime
/// remain hidden behind this API.
class FaceVerificationSdk {
  /// Creates the Face Verification SDK.
  ///
  /// [similarityThreshold] is the minimum cosine similarity
  /// required for a successful verification.
  ///
  /// The currently validated threshold is 0.35.
  FaceVerificationSdk({
    double similarityThreshold = 0.35,
  }) : _similarityThreshold = similarityThreshold;

  final double _similarityThreshold;

  // ------------------------------------------------------------
  // Internal services
  // ------------------------------------------------------------

  late final IImagePreprocessorService _preprocessor;
  late final IOnnxRuntimeService _runtime;
  late final IEmbeddingService _embeddingService;
  late final IFaceDetectorService _faceDetector;
  late final ISimilarityService _similarityService;

  late final IEnrollmentService _enrollmentService;
  late final IVerificationService _verificationService;

  late final LocalImageProvider _imageProvider;

  bool _initialized = false;

  // ------------------------------------------------------------
  // Public properties
  // ------------------------------------------------------------

  /// Whether the SDK has been initialized.
  bool get isInitialized => _initialized;

  /// Similarity threshold configured for this SDK instance.
  double get similarityThreshold => _similarityThreshold;

  // ------------------------------------------------------------
  // Initialization
  // ------------------------------------------------------------

  /// Initializes all SDK services and loads the ArcFace model.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // ----------------------------------------------------------
    // Image preprocessing
    // ----------------------------------------------------------

    const faceCropper = FaceCropperService();
    const imageResizer = ImageResizer();
    const imageNormalizer = ImageNormalizer();

    _preprocessor = ImagePreprocessorService(
      faceCropper: faceCropper,
      imageResizer: imageResizer,
      imageNormalizer: imageNormalizer,
    );

    // ----------------------------------------------------------
    // ONNX Runtime
    // ----------------------------------------------------------

    _runtime = OnnxRuntimeService();

    // ----------------------------------------------------------
    // ArcFace embedding service
    // ----------------------------------------------------------

    _embeddingService = ArcFaceService(
      preprocessor: _preprocessor,
      runtime: _runtime,
    );

    // ----------------------------------------------------------
    // ML Kit face detector
    // ----------------------------------------------------------

    _faceDetector = FaceDetectorService();

    // ----------------------------------------------------------
    // Cosine similarity
    // ----------------------------------------------------------

    _similarityService = CosineSimilarityService(
      threshold: _similarityThreshold,
    );

    // ----------------------------------------------------------
    // Image provider
    // ----------------------------------------------------------

    _imageProvider = const LocalImageProvider();

    // ----------------------------------------------------------
    // Enrollment service
    // ----------------------------------------------------------

    _enrollmentService = EnrollmentService(
      imageProvider: _imageProvider,
      faceDetector: _faceDetector,
      embeddingService: _embeddingService,
    );

    // ----------------------------------------------------------
    // Verification service
    // ----------------------------------------------------------

    _verificationService = VerificationService(
      faceDetector: _faceDetector,
      embeddingService: _embeddingService,
      similarityService: _similarityService,
    );

    // ----------------------------------------------------------
    // Load ArcFace ONNX model
    // ----------------------------------------------------------

    await _runtime.initialize();

    _initialized = true;
  }

  // ------------------------------------------------------------
  // Enrollment
  // ------------------------------------------------------------

  /// Generates a face embedding from a supplied student image.
  ///
  /// The image passes through:
  ///
  /// ML Kit
  /// ↓
  /// Face detection
  /// ↓
  /// Face crop
  /// ↓
  /// 112 × 112 resize
  /// ↓
  /// Normalization
  /// ↓
  /// ArcFace
  /// ↓
  /// ONNX Runtime
  /// ↓
  /// 512-dimensional embedding
  ///
  /// The returned [FaceEmbedding] should be stored by the
  /// company application's database/server.
  Future<FaceEmbedding> enroll({
    required String studentId,
    required RawFaceImage image,
  }) async {
    _ensureInitialized();

    try {
      final detection =
          await _faceDetector.detectFace(image);

      final vector =
          await _embeddingService.generateEmbedding(
        detection,
      );

      return FaceEmbedding(
        studentId: studentId,
        vector: vector,
        generatedAt: DateTime.now(),
      );
    } on FaceVerificationException {
      rethrow;
    } catch (e) {
      throw EmbeddingGenerationException(
        'Unable to generate enrollment embedding: $e',
      );
    }
  }

  /// Enrolls a student using the SDK's configured image provider.
  ///
  /// This method is mainly intended for the SDK example application.
  ///
  /// The company application should normally use [enroll] and provide
  /// its own downloaded/enrolled image.
  Future<FaceEmbedding> enrollStudent({
    required String studentId,
  }) async {
    _ensureInitialized();

    try {
      return await _enrollmentService.enrollStudent(
        studentId: studentId,
      );
    } on FaceVerificationException {
      rethrow;
    } catch (e) {
      throw EmbeddingGenerationException(
        'Unable to enroll student: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // Verification
  // ------------------------------------------------------------

  /// Verifies a captured face against an enrolled face embedding.
  ///
  /// Returns a [VerificationResult] containing:
  ///
  /// - student ID
  /// - similarity score
  /// - configured threshold
  /// - verification status
  Future<VerificationResult> verify({
    required FaceEmbedding enrolledEmbedding,
    required RawFaceImage image,
  }) async {
    _ensureInitialized();

    try {
      return await _verificationService.verify(
        enrolledEmbedding: enrolledEmbedding,
        verificationImage: image,
      );
    } on FaceVerificationException {
      rethrow;
    } catch (e) {
      throw VerificationFailedException(
        'Unable to verify face: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // Dispose
  // ------------------------------------------------------------

  /// Releases native resources used by the SDK.
  Future<void> dispose() async {
    if (!_initialized) {
      return;
    }

    await _faceDetector.dispose();
    await _runtime.dispose();

    _initialized = false;
  }

  // ------------------------------------------------------------
  // Internal validation
  // ------------------------------------------------------------

  void _ensureInitialized() {
    if (!_initialized) {
      throw const SdkNotInitializedException();
    }
  }
}

// ============================================================
// PUBLIC MODELS
// ============================================================

