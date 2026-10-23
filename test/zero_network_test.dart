import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release Android manifest has zero network permissions', () async {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest.contains('android.permission.INTERNET'), isFalse,
        reason: 'release build must request no network access');
    expect(manifest.contains('ACCESS_NETWORK_STATE'), isFalse);
  });

  test('debug manifest keeps INTERNET only for dev tooling', () async {
    final manifest = File(
      'android/app/src/debug/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest.contains('android.permission.INTERNET'), isTrue);
  });
}
