import 'package:local_auth/local_auth.dart';

/// Port over the platform biometric API. The app layer implements with
/// local_auth; tests use fakes that script the outcome.
abstract class BiometricPort {
  /// True when hardware exists AND at least one biometric is enrolled.
  Future<bool> canUseBiometrics();

  /// Runs the platform biometric prompt. Returns the OS verdict.
  Future<BiometricResult> authenticate({required String reason});
}

enum BiometricResult { success, failed, permanentlyUnavailable }

class LocalAuthBiometricPort implements BiometricPort {
  LocalAuthBiometricPort();

  @override
  Future<bool> canUseBiometrics() async {
    final auth = LocalAuthentication();
    return await auth.canCheckBiometrics && await auth.isDeviceSupported();
  }

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(
        localizedReason: reason,
        sensitiveTransaction: true,
        biometricOnly: true,
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } catch (_) {
      return BiometricResult.permanentlyUnavailable;
    }
  }
}
