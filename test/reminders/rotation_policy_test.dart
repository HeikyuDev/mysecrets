import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/reminders/rotation_policy.dart';
import 'package:mysecrets/vault/credential.dart';

DateTime _dt(int daysAgo) =>
    DateTime.now().toUtc().subtract(Duration(days: daysAgo, hours: 0));

Credential _cred({required DateTime lastChanged, int? policy}) => Credential(
      id: 'c-${lastChanged.millisecondsSinceEpoch}',
      platform: 'P',
      username: 'u',
      password: 'p',
      createdAtUtc: lastChanged,
      updatedAtUtc: lastChanged,
      lastChangedUtc: lastChanged,
      rotationPolicyDays: policy,
    );

void main() {
  group('RotationPolicy.isDue', () {
    test('no policy means never due', () {
      final c = _cred(lastChanged: _dt(400), policy: null);
      expect(
          RotationPolicy.isDue(
            lastChangedUtc: c.lastChangedUtc,
            policyDays: null,
            nowUtc: DateTime.now().toUtc(),
          ),
          isFalse);
    });

    test('age below policy is not due', () {
      final last = _dt(89);
      expect(
          RotationPolicy.isDue(
              lastChangedUtc: last,
              policyDays: 90,
              nowUtc: DateTime.now().toUtc()),
          isFalse);
    });

    test('age at or beyond policy is due', () {
      final last = _dt(90);
      final now = DateTime.now().toUtc();
      expect(
          RotationPolicy.isDue(
              lastChangedUtc: last, policyDays: 90, nowUtc: now),
          isTrue);
    });

    test('daysOverdue counts excess', () {
      final last = _dt(95);
      final now = DateTime.now().toUtc();
      expect(
        RotationPolicy.daysOverdue(
            lastChangedUtc: last, policyDays: 90, nowUtc: now),
        inInclusiveRange(4, 5),
      );
      expect(
        RotationPolicy.daysOverdue(
            lastChangedUtc: _dt(30), policyDays: 90, nowUtc: now),
        0,
      );
    });

    test('rejects non-positive policy', () {
      expect(
        () => RotationPolicy.isDue(
            lastChangedUtc: _dt(1), policyDays: 0, nowUtc: _dt(0)),
        throwsArgumentError,
      );
    });
  });
}
