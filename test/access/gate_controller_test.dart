import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/access/biometric_port.dart';
import 'package:mysecrets/access/gate_controller.dart';
import 'package:mysecrets/access/pin_service.dart';

import 'fakes.dart';
import '../vault/keys/in_memory_key_store.dart';

void main() {
  late InMemoryKeyStore keyStore;
  late InMemoryQuickUnlockStore quickUnlockStore;
  late PinService pinService;

  setUp(() {
    keyStore = InMemoryKeyStore();
    quickUnlockStore = InMemoryQuickUnlockStore();
    pinService = PinService();
  });

  GateController buildGate(BiometricResult result, {bool hw = true}) =>
      GateController(
        pinService: pinService,
        keyStore: keyStore,
        quickUnlockStore: quickUnlockStore,
        biometricPort: StubBiometricPort(
            hardwareAvailable: hw, results: [result]),
      );

  final dek = Uint8List.fromList(List.filled(32, 7));

  test('enroll stores PIN hash and DEK under quick unlock', () async {
    final gate = buildGate(BiometricResult.success);
    await gate.enrollQuickUnlock(pin: '123456', dek: dek);

    expect(await gate.hasPinEnrolled, isTrue);
    expect(await gate.hasQuickUnlock, isTrue);
    final stored = await quickUnlockStore.retrieve();
    expect(stored, dek);
  });

  test('enroll rejects non-6-digit PINs', () async {
    final gate = buildGate(BiometricResult.success);
    for (final bad in ['12345', '1234567', 'abc123', '12 456']) {
      await expectLater(
        gate.enrollQuickUnlock(pin: bad, dek: dek),
        throwsArgumentError,
      );
    }
    expect(await gate.hasPinEnrolled, isFalse);
  });

  test('correct PIN unlocks', () async {
    final gate = buildGate(BiometricResult.success);
    await gate.enrollQuickUnlock(pin: '654321', dek: dek);
    final decision = await gate.unlockWithPin('654321');
    expect(decision.unlocked, isTrue);
  });

  test('wrong PIN fails and applies progressive backoff', () async {
    final gate = buildGate(BiometricResult.success);
    await gate.enrollQuickUnlock(pin: '654321', dek: dek);

    final first = await gate.unlockWithPin('000000');
    expect(first.unlocked, isFalse);
    expect(first.retryAfterSeconds, 2);

    final second = await gate.unlockWithPin('000000');
    expect(second.retryAfterSeconds, 2);
    expect(second.unlocked, isFalse);

    gate.reset();
    final recovered = await gate.unlockWithPin('654321');
    expect(recovered.unlocked, isTrue);
  });

  test('biometric success unlocks', () async {
    final gate = buildGate(BiometricResult.success);
    await gate.enrollQuickUnlock(pin: '111111', dek: dek);
    final decision = await gate.unlockWithBiometrics();
    expect(decision.unlocked, isTrue);
  });

  test('biometric failure falls back to PIN unlock', () async {
    final gate = buildGate(BiometricResult.failed);
    await gate.enrollQuickUnlock(pin: '111111', dek: dek);
    final bio = await gate.unlockWithBiometrics();
    expect(bio.unlocked, isFalse);
    final viaPin = await gate.unlockWithPin('111111');
    expect(viaPin.unlocked, isTrue);
  });

  test('PIN verify returns false when nothing enrolled', () async {
    expect(
      await pinService.verify(store: keyStore, pin: '123456'),
      isFalse,
    );
  });
}
