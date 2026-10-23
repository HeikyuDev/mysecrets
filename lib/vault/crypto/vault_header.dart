import 'dart:typed_data';

const List<int> vaultMagic = [0x4D, 0x59, 0x53, 0x45, 0x43];

const int currentVaultFormatVersion = 1;

class VaultHeader {
  final int formatVersion;
  final int iterations;
  final int memoryKiB;
  final int lanes;
  final Uint8List salt;

  VaultHeader._({
    required this.formatVersion,
    required this.iterations,
    required this.memoryKiB,
    required this.lanes,
    required this.salt,
  });

  static VaultHeader create({
    required int iterations,
    required int memoryKiB,
    required int lanes,
    required Uint8List salt,
  }) =>
      VaultHeader._(
        formatVersion: currentVaultFormatVersion,
        iterations: iterations,
        memoryKiB: memoryKiB,
        lanes: lanes,
        salt: Uint8List.fromList(salt),
      );

  static VaultHeader decode(Uint8List bytes) {
    if (bytes.length < 5 + 1) {
      throw VaultHeaderException('header too short');
    }
    for (var i = 0; i < vaultMagic.length; i++) {
      if (bytes[i] != vaultMagic[i]) {
        throw VaultHeaderException('not a mySecrets vault file');
      }
    }
    final version = bytes[5];
    if (version > currentVaultFormatVersion) {
      throw VaultHeaderException(
          'unsupported vault format version: $version');
    }
    if (bytes.length < 16) {
      throw VaultHeaderException('header too short for version $version');
    }
    final data = ByteData.sublistView(bytes);
    if (version == 1) {
      final iterations = data.getUint32(6, Endian.little);
      final memoryKiB = data.getUint32(10, Endian.little);
      final lanes = data.getUint8(14);
      final saltLength = data.getUint8(15);
      const saltOffset = 16;
      if (saltLength > bytes.length - saltOffset) {
        throw VaultHeaderException('header salt truncated');
      }
      return VaultHeader._(
        formatVersion: version,
        iterations: iterations,
        memoryKiB: memoryKiB,
        lanes: lanes,
        salt: Uint8List.sublistView(bytes, saltOffset, saltOffset + saltLength),
      );
    }
    throw VaultHeaderException('unsupported vault format version: $version');
  }

  Uint8List encode() {
    final out = BytesBuilder();
    out.add(vaultMagic);
    out.addByte(formatVersion);
    final data = ByteData(8)
      ..setUint32(0, iterations, Endian.little)
      ..setUint32(4, memoryKiB, Endian.little);
    out.add(data.buffer.asUint8List());
    out.addByte(lanes);
    out.addByte(salt.length);
    out.add(salt);
    return out.toBytes();
  }
}

class VaultHeaderException implements Exception {
  final String message;

  VaultHeaderException(this.message);

  @override
  String toString() => 'VaultHeaderException: $message';
}
