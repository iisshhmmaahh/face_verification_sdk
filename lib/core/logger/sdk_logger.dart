import '../config/sdk_config.dart';

/// Centralized logger used by the SDK.
///
/// All logs should go through this class.
class SdkLogger {
  SdkLogger._();

  static bool _enabled = true;

  /// Initializes the logger.
  static void initialize(SdkConfig config) {
    _enabled = config.enableLogging;
  }

  static void info(String message) {
    if (!_enabled) return;
    // ignore: avoid_print
    print('[INFO] $message');
  }

  static void warning(String message) {
    if (!_enabled) return;
    // ignore: avoid_print
    print('[WARNING] $message');
  }

  static void error(String message) {
    if (!_enabled) return;
    // ignore: avoid_print
    print('[ERROR] $message');
  }
}