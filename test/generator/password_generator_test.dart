import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/generator/password_generator.dart';
import 'package:mysecrets/generator/passphrase_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('output length matches configuration', () {
      expect(PasswordGenerator.generate(const GeneratorConfig(length: 20)),
          hasLength(20));
      expect(PasswordGenerator.generate(const GeneratorConfig(length: 64)),
          hasLength(64));
    });

    test('output contains only enabled classes and at least one per class',
        () {
      const config = GeneratorConfig(
          length: 32, upper: true, lower: true, digits: true, symbols: false);
      final p = PasswordGenerator.generate(config);
      expect(p.contains(' '), isFalse, reason: 'no space in pool');
      expect(p.split('').every((c) {
        return PasswordGenerator.upper.contains(c) ||
            PasswordGenerator.lower.contains(c) ||
            PasswordGenerator.digits.contains(c);
      }), isTrue);
      expect(p.split('').any((c) => PasswordGenerator.upper.contains(c)),
          isTrue);
      expect(p.split('').any((c) => PasswordGenerator.lower.contains(c)),
          isTrue);
      expect(p.split('').any((c) => PasswordGenerator.digits.contains(c)),
          isTrue);
    });

    test('rejects config with no classes', () {
      expect(
        () => PasswordGenerator.generate(const GeneratorConfig(
            upper: false, lower: false, digits: false, symbols: false)),
        throwsArgumentError,
      );
    });

    test('rejects length shorter than number of enabled classes', () {
      expect(
        () => PasswordGenerator.generate(const GeneratorConfig(length: 2)),
        throwsArgumentError,
      );
    });

    test('consecutive outputs differ (no constant output)', () {
      final outs = List.generate(50,
          (_) => PasswordGenerator.generate(const GeneratorConfig()));
      expect(outs.toSet().length, greaterThan(45));
    });

    test('entropy bits match log2(charsetSize^length)', () {
      final bits = PasswordGenerator.entropyBits(const GeneratorConfig(
          length: 20,
          upper: true,
          lower: true,
          digits: true,
          symbols: true));
      final setSize = PasswordGenerator.upper.length * 2 +
          PasswordGenerator.digits.length +
          PasswordGenerator.symbols.length;
      expect(bits, closeTo(20 * (log(setSize) / log(2)), 0.001));
    });

    test('entropy grows with length and label ladder is ordered', () {
      final short = PasswordGenerator.entropyBits(
          const GeneratorConfig(length: 12, symbols: false));
      final long = PasswordGenerator.entropyBits(
          const GeneratorConfig(length: 40, symbols: false));
      expect(long, greaterThan(short));
      expect(
          PasswordGenerator.labelFor(40), StrengthLabel.weak);
      expect(
          PasswordGenerator.labelFor(90), StrengthLabel.good);
      expect(
          PasswordGenerator.labelFor(120), StrengthLabel.strong);
      expect(
          PasswordGenerator.labelFor(140), StrengthLabel.excellent);
    });
  });

  group('PassphraseGenerator', () {
    test('word count matches configuration', () {
      expect(PassphraseGenerator.generate(words: 3)
          .split(PassphraseGenerator.defaultSeparator), hasLength(3));
      expect(PassphraseGenerator.generate(words: 8)
          .split(PassphraseGenerator.defaultSeparator), hasLength(8));
    });

    test('rejects word count outside 3..8', () {
      expect(() => PassphraseGenerator.generate(words: 2), throwsArgumentError);
      expect(() => PassphraseGenerator.generate(words: 9), throwsArgumentError);
    });

    test('consecutive passphrases differ', () {
      final outs = List.generate(20, (_) => PassphraseGenerator.generate());
      expect(outs.toSet().length, greaterThan(15));
    });

    test('entropy per word is honest for the bundled list size', () {
      expect(PassphraseGenerator.entropyBitsPerWord(),
          closeTo(log(passphraseWords.length) / log(2), 0.001));
      expect(PassphraseGenerator.entropyBits(8),
          greaterThan(8 * log(64) / log(2) - 1));
    });
  });
}
