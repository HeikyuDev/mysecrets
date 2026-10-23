import 'package:mysecrets/reminders/rotation_policy.dart';
import 'package:mysecrets/vault/credential.dart';
abstract class NotifierPort {
  Future<void> notify(Credential credential, int daysOverdue);

  Future<void> clearFor(String credentialId);
}

/// Computes and posts reminders for credentials that are due for rotation.
/// Pure orchestration over RotationPolicy + a NotifierPort; the caller (app
/// layer) re-runs it on vault unlock and whenever the credentials list
/// changes.
class ReminderService {
  final NotifierPort _notifier;

  ReminderService({required this._notifier});

  /// Returns the ids considered due and posts one notification per due
  /// credential. Week re-notification is the app layer's responsibility to
  /// re-invoke periodically; this method is idempotent per invocation.
  Future<List<Credential>> process({
    required List<Credential> credentials,
    required DateTime nowUtc,
  }) async {
    final due = <String>{};
    final dueCredentials = credentials.where((c) {
      final ok = RotationPolicy.isDue(
        lastChangedUtc: c.lastChangedUtc,
        policyDays: c.rotationPolicyDays,
        nowUtc: nowUtc,
      );
      if (ok) due.add(c.id);
      return ok;
    }).toList();

    for (final c in dueCredentials) {
      await _notifier.notify(
        c,
        RotationPolicy.daysOverdue(
          lastChangedUtc: c.lastChangedUtc,
          policyDays: c.rotationPolicyDays,
          nowUtc: nowUtc,
        ),
      );
    }
    for (final c in credentials) {
      if (!due.contains(c.id)) {
        await _notifier.clearFor(c.id);
      }
    }
    return dueCredentials;
  }
}
