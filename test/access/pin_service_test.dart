import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/access/pin_service.dart';
import 'package:mysecrets/vault/keys/vault_key_store.dart';

import '../vault/keys/in_memory_key_store.dart';

void main() {
  final pinService = PinService();
  late InMemoryKeyStore keyStore;

  setUp(() => keyStore = InMemoryKeyStore());

  test('enroll then verify works for the right PIN', () async {
    await pinService.enroll(store: keyStore, pin: '987654');
    expect(await pinService.verify(store: keyStore, pin: '987654'), isTrue);
    expect(await pinService.verify(store: keyStore, pin: '123456'), isFalse);
  });

  test('stored blob is salt+hash, salts differ across enrolls', () async {
    await pinService.enroll(store: keyStore, pin: '111111');
    final first = await keyStore.load(VaultKeyStore.pinHashKey);
    await pinService.enroll(store: keyStore, pin: '111111');
    final second = await keyStore.load(VaultKeyStore.pinHashKey);

    expect(first, isNotNull);
    expect(first!.length, PinService.saltLength + PinService.hashLength);
    expect(
      Uint8List.sublistView(first, 0, PinService.saltLength),
      isNot(equals(Uint8List.sublistView(second!, 0, PinService.saltLength))),
    );
  });
}
