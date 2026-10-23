import 'dart:typed_data';

import 'package:mysecrets/access/biometric_port.dart';
import 'package:mysecrets/access/quick_unlock_store.dart';

class InMemoryQuickUnlockStore implements QuickUnlockStore {
  Uint8List? _dek;

  @override
  Future<bool> get isEnrolled async => _dek != null;

  @override
  Future<void> enroll(Uint8List dek) async => _dek = Uint8List.fromList(dek);

  @override
  Future<Uint8List?> retrieve() async =>
      _dek == null ? null : Uint8List.fromList(_dek!);

  @override
  Future<void> clear() async => _dek = null;
}

class StubBiometricPort implements BiometricPort {
  final bool hardwareAvailable;
  final List<BiometricResult> results;
  int _index = 0;

  StubBiometricPort(
      {this.hardwareAvailable = true,
      List<BiometricResult>? results})
      : results = results ??
            const [BiometricResult.success];

  @override
  Future<bool> canUseBiometrics() async => hardwareAvailable;

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    if (_index >= results.length) {
      return results.last;
    }
    return results[_index++];
  }
}
