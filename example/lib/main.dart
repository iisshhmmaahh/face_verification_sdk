import 'dart:async';


import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:face_verification_sdk/face_verification_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final cameras = await availableCameras();

    runApp(
      CameraExampleApp(
        cameras: cameras,
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to access camera.\n\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraExampleApp extends StatelessWidget {
  const CameraExampleApp({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: VerificationPage(
        cameras: cameras,
      ),
    );
  }
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<VerificationPage> createState() =>
      _VerificationPageState();
}

class _VerificationPageState
    extends State<VerificationPage> {
  // ============================================================
  // SDK
  // ============================================================

  final FaceVerificationSdk _sdk =
      FaceVerificationSdk(
    similarityThreshold: 0.30,
  );

  // ============================================================
  // CAMERA
  // ============================================================

  CameraController? _cameraController;

  // ============================================================
  // VERIFICATION STATE
  // ============================================================

  Timer? _verificationTimer;

  FaceEmbedding? _enrolledEmbedding;

  bool _initializing = true;
  bool _verifying = false;
  bool _verificationComplete = false;
  bool _verified = false;

  String _statusMessage =
      'Starting verification...';

  String? _errorMessage;

  double? _similarityScore;

  static const String studentId = 'student1';

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startVerification();
  }

  // ============================================================
  // START VERIFICATION
  // ============================================================

  Future<void> _startVerification() async {
    _verificationTimer?.cancel();

    // Dispose old camera before creating another one.
    final oldController = _cameraController;
    _cameraController = null;

    if (oldController != null) {
      await oldController.dispose();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _initializing = true;
      _verifying = false;
      _verificationComplete = false;
      _verified = false;

      _statusMessage =
          'Starting verification...';

      _errorMessage = null;
      _similarityScore = null;
      _enrolledEmbedding = null;
    });

    try {
      // ----------------------------------------------------------
      // 1. INITIALIZE SDK
      // ----------------------------------------------------------

      await _sdk.initialize();

      // ----------------------------------------------------------
      // 2. LOAD ENROLLED STUDENT IMAGE
      //
      // Example/demo only.
      //
      // Production:
      //
      // Server/cloud image
      //       ↓
      // Uint8List
      //       ↓
      // RawFaceImage
      //       ↓
      // SDK enrollment
      // ----------------------------------------------------------

      final ByteData data = await rootBundle.load(
        'packages/face_verification_sdk/'
        'assets/sample_data/$studentId.jpg',
      );

      final Uint8List enrolledBytes =
          data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      final RawFaceImage enrolledRawImage =
          RawFaceImage(
        bytes: enrolledBytes,
      );

      // ----------------------------------------------------------
      // 3. GENERATE ENROLLED EMBEDDING
      // ----------------------------------------------------------

      final FaceEmbedding enrolledEmbedding =
          await _sdk.enroll(
        studentId: studentId,
        image: enrolledRawImage,
      );

      // ----------------------------------------------------------
      // 4. CHECK CAMERA
      // ----------------------------------------------------------

      if (widget.cameras.isEmpty) {
        throw Exception(
          'No camera was found on this device.',
        );
      }

      // ----------------------------------------------------------
      // 5. FIND FRONT CAMERA
      // ----------------------------------------------------------

      final CameraDescription frontCamera =
          widget.cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      );

      // ----------------------------------------------------------
      // 6. INITIALIZE CAMERA
      //
      // Preview is intentionally NOT displayed.
      // The camera is used only for capturing the face.
      // ----------------------------------------------------------

      final CameraController controller =
          CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _enrolledEmbedding =
            enrolledEmbedding;

        _cameraController = controller;

        _initializing = false;

        _statusMessage =
            'Position your face inside the circle';
      });

      // ----------------------------------------------------------
      // 7. GIVE CAMERA TIME TO STABILIZE
      // ----------------------------------------------------------

      await Future.delayed(
        const Duration(
          milliseconds: 800,
        ),
      );

      if (!mounted) {
        return;
      }

      _scheduleVerification();

    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _initializing = false;

        _errorMessage = e.toString();

        _statusMessage =
            'Verification could not start';
      });
    }
  }

  // ============================================================
  // SCHEDULE VERIFICATION
  // ============================================================

  void _scheduleVerification({
    int milliseconds = 800,
  }) {
    _verificationTimer?.cancel();

    _verificationTimer = Timer(
      Duration(
        milliseconds: milliseconds,
      ),
      () {
        if (!mounted) {
          return;
        }

        if (_verificationComplete ||
            _verifying) {
          return;
        }

        _verifyCurrentFace();
      },
    );
  }

  // ============================================================
  // VERIFY CURRENT FACE
  // ============================================================

  Future<void> _verifyCurrentFace() async {
    if (!mounted) {
      return;
    }

    if (_verifying ||
        _verificationComplete) {
      return;
    }

    final CameraController? controller =
        _cameraController;

    final FaceEmbedding? enrolled =
        _enrolledEmbedding;

    if (controller == null ||
        !controller.value.isInitialized ||
        enrolled == null) {
      return;
    }

    setState(() {
      _verifying = true;

      _statusMessage =
          'Verifying your identity...';
    });

    try {
      // ----------------------------------------------------------
      // 1. CAPTURE IMAGE
      // ----------------------------------------------------------

      final XFile picture =
          await controller.takePicture();

      // ----------------------------------------------------------
      // 2. READ IMAGE BYTES
      // ----------------------------------------------------------

      final Uint8List bytes =
          await picture.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'The captured image is empty.',
        );
      }

      // ----------------------------------------------------------
      // 3. CREATE SDK IMAGE
      // ----------------------------------------------------------

      final RawFaceImage rawImage =
          RawFaceImage(
        bytes: bytes,
      );

      // ----------------------------------------------------------
      // 4. VERIFY
      // ----------------------------------------------------------

      final VerificationResult result =
          await _sdk.verify(
        enrolledEmbedding: enrolled,
        image: rawImage,
      );

      if (!mounted) {
        return;
      }

      // ----------------------------------------------------------
      // 5. DISPLAY FINAL RESULT
      // ----------------------------------------------------------

      setState(() {
        _similarityScore =
            result.similarityScore;

        _verified =
            result.isVerified;

        _verificationComplete = true;

        _verifying = false;

        if (result.isVerified) {
          _statusMessage =
              'Identity verified successfully.';
        } else {
          _statusMessage =
              'The face does not match '
              'the enrolled identity.';
        }
      });

      _verificationTimer?.cancel();

    } catch (e) {
      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // TEMPORARY FACE/CAMERA PROCESSING FAILURE
      //
      // Keep trying because the student may simply not be
      // positioned correctly.
      // --------------------------------------------------------

      setState(() {
        _verifying = false;

        _statusMessage =
            _friendlyErrorMessage(e);
      });

      _scheduleVerification(
        milliseconds: 1200,
      );
    }
  }

  // ============================================================
  // FRIENDLY ERROR MESSAGE
  // ============================================================

  String _friendlyErrorMessage(
    Object error,
  ) {
    final String message =
        error.toString().toLowerCase();

    if (message.contains('no face')) {
      return 'No face detected. '
          'Please position your face correctly.';
    }

    if (message.contains('multiple')) {
      return 'Multiple faces detected. '
          'Only one person should be visible.';
    }

    if (message.contains('invalid')) {
      return 'Unable to process the image. '
          'Please try again.';
    }

    return 'Unable to verify. '
        'Please keep your face steady.';
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<void> _retryVerification() async {
    await _startVerification();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _verificationTimer?.cancel();

    final CameraController? controller =
        _cameraController;

    if (controller != null) {
      unawaited(
        controller.dispose(),
      );
    }

    unawaited(
      _sdk.dispose(),
    );

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    // ----------------------------------------------------------
    // INITIALIZING
    // ----------------------------------------------------------

    if (_initializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Preparing face verification...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // INITIALIZATION ERROR
    // ----------------------------------------------------------

    if (_errorMessage != null &&
        !_verificationComplete) {
      return _buildErrorScreen();
    }

    // ----------------------------------------------------------
    // STATUS
    // ----------------------------------------------------------

    final bool isComplete =
        _verificationComplete;

    final Color statusColor =
        _verified
            ? Colors.green
            : isComplete
                ? Colors.red
                : Colors.blue;

    final IconData statusIcon =
        _verified
            ? Icons.check_circle_rounded
            : isComplete
                ? Icons.cancel_rounded
                : Icons.face_rounded;

    final String title =
        _verified
            ? 'Face Verified'
            : isComplete
                ? 'Face Not Verified'
                : 'Face Verification';

    final String instruction =
        _verified
            ? 'Identity verified successfully'
            : isComplete
                ? 'The face does not match '
                  'the enrolled identity'
                : 'Position your face inside '
                  'the circle';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                const Text(
                  'Face Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Secure identity verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 55),

                // ------------------------------------------------
                // FACE CIRCLE
                // ------------------------------------------------

                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),
                  width: 200,
                  height: 200,
                  decoration:
                      BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(
                      alpha: 0.08,
                    ),
                    border: Border.all(
                      color: statusColor,
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    statusIcon,
                    size: 88,
                    color: statusColor,
                  ),
                ),

                const SizedBox(height: 38),

                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------
                // INSTRUCTION
                // ------------------------------------------------

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // VERIFYING INDICATOR
                // ------------------------------------------------

                if (_verifying) ...[
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Analyzing face...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],

                // ------------------------------------------------
                // STATUS MESSAGE
                // ------------------------------------------------

                if (!_verifying)
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),

                // ------------------------------------------------
                // SIMILARITY SCORE
                // ------------------------------------------------

                if (_similarityScore != null) ...[
                  const SizedBox(height: 18),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color:
                          statusColor.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      'Similarity  •  '
                      '${_similarityScore!.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],

                // ------------------------------------------------
                // RETRY
                // ------------------------------------------------

                if (_verificationComplete) ...[
                  const SizedBox(height: 30),

                  SizedBox(
                    width: 180,
                    height: 48,
                    child: OutlinedButton(
                      onPressed:
                          _retryVerification,
                      child: const Text(
                        'Verify Again',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR SCREEN
  // ============================================================

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(
                      alpha: 0.08,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Verification Unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _errorMessage ??
                      'Unable to start verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: 180,
                  height: 48,
                  child: FilledButton(
                    onPressed:
                        _retryVerification,
                    child: const Text(
                      'Try Again',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}