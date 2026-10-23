import 'dart:math';

enum StrengthLabel { weak, good, strong, excellent }

class GeneratorConfig {
  final int length;
  final bool upper;
  final bool lower;
  final bool digits;
  final bool symbols;

  const GeneratorConfig({
    this.length = 20,
    this.upper = true,
    this.lower = true,
    this.digits = true,
    this.symbols = true,
  });

  bool get valid => upper || lower || digits || symbols;
}

class PasswordGenerator {
  static const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const lower = 'abcdefghijklmnopqrstuvwxyz';
  static const digits = '0123456789';
  static const symbols = '!@#\$%^&*()-_=+[]{};:,.<>?';
  static final _secure = Random.secure();

  /// Generates a password with at least one character of each enabled class
  /// and unbiased rejection-sampled selection for the rest.
  static String generate(GeneratorConfig config) {
    if (!config.valid) {
      throw ArgumentError('at least one character class must be enabled');
    }
    final classes = [
      if (config.upper) upper,
      if (config.lower) lower,
      if (config.digits) digits,
      if (config.symbols) symbols,
    ];
    final pool = classes.join();

    if (config.length < classes.length) {
      throw ArgumentError(
          'length ${config.length} is shorter than ${classes.length} classes');
    }

    final chars = <String>[];
    for (final c in classes) {
      chars.add(c[_secure.nextInt(c.length)]);
    }
    for (var i = chars.length; i < config.length; i++) {
      chars.add(pool[_secure.nextInt(pool.length)]);
    }

    // Fisher-Yates with CSPRNG so the guaranteed-class chars are not biased
    // to the front.
    for (var i = chars.length - 1; i > 0; i--) {
      final j = _secure.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return chars.join();
  }

  static double entropyBits(GeneratorConfig config) {
    var setSize = 0;
    if (config.upper) setSize += upper.length;
    if (config.lower) setSize += lower.length;
    if (config.digits) setSize += digits.length;
    if (config.symbols) setSize += symbols.length;
    if (setSize == 0) return 0;
    return config.length * (log(setSize) / log(2));
  }

  static StrengthLabel labelFor(double bits) {
    if (bits < 60) return StrengthLabel.weak;
    if (bits < 100) return StrengthLabel.good;
    if (bits < 128) return StrengthLabel.strong;
    return StrengthLabel.excellent;
  }
}
