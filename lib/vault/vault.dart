import 'dart:typed_data';

import 'crypto/key_derivation_service.dart';
import 'crypto/vault_cipher.dart';
import 'crypto/vault_header.dart';
import 'crypto/vault_random.dart';

class Vault {
  Vault._();

  static Uint8List newDek() => VaultRandom.dek();

  static Uint8List seal({
    required String masterPassphrase,
    required Uint8List dek,
    required Uint8List payload,
    int iterations = defaultIterations,
    int memoryKiB = defaultMemoryKiB,
    int lanes = defaultLanes,
  }) {
    final salt = KeyDerivationService.newSalt();
    final header = VaultHeader.create(
      iterations: iterations,
      memoryKiB: memoryKiB,
      lanes: lanes,
      salt: salt,
    );
    final kek = KeyDerivationService.deriveKek(
      masterPassphrase: masterPassphrase,
      salt: Uint8List.fromList(salt),
      iterations: iterations,
      memoryKiB: memoryKiB,
      lanes: lanes,
    );
    final sealedDek = VaultCipher.encrypt(key: kek, plaintext: dek);
    final sealedPayload =
        VaultCipher.encrypt(key: dek, plaintext: payload, associatedData: header.encode());

    final out = BytesBuilder();
    out.add(header.encode());
    out.add(sealedDek);
    out.add(sealedPayload);
    return out.toBytes();
  }

  static Uint8List unsealDek({
    required String masterPassphrase,
    required Uint8List vaultFile,
  }) {
    final header = VaultHeader.decode(vaultFile);
    const dekLengthWithNonceAndTag = 12 + 32 + 16;
    if (vaultFile.length < header.encode().length + dekLengthWithNonceAndTag) {
      throw VaultCipherException('vault file truncated');
    }
    final kek = KeyDerivationService.deriveKek(
      masterPassphrase: masterPassphrase,
      salt: Uint8List.fromList(header.salt),
      iterations: header.iterations,
      memoryKiB: header.memoryKiB,
      lanes: header.lanes,
    );
    final headerLength = header.encode().length;
    final sealedDek =
        Uint8List.sublistView(vaultFile, headerLength, headerLength + 12 + 32 + 16);
    return VaultCipher.decrypt(key: kek, sealed: sealedDek);
  }

  static Uint8List unsealPayload({
    required String masterPassphrase,
    required Uint8List vaultFile,
  }) {
    final dek = unsealDek(
        masterPassphrase: masterPassphrase, vaultFile: vaultFile);
    final header = VaultHeader.decode(vaultFile);
    final headerLength = header.encode().length;
    const sealedDekLength = 12 + 32 + 16;
    final sealedPayload =
        Uint8List.sublistView(vaultFile, headerLength + sealedDekLength);
    return VaultCipher.decrypt(
        key: dek, sealed: sealedPayload, associatedData: header.encode());
  }
}
