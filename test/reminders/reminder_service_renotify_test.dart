import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/reminders/reminder_service.dart';
import 'package:mysecrets/vault/credential.dart';

class RecordingNotifier implements NotifierPort {
  final notifiedIds = <String>[];
  final clearedIds = <String>[];

  @override
  Future<void> notify(Credential credential, int daysOverdue) async {
    notifiedIds.add(credential.id);
  }

  @override
  Future<void> clearFor(String credentialId) async {
    clearedIds.add(credentialId);
  }
}

Credential _cred(String id, {required int policyDays, required int ageDays}) {
  final now = DateTime.now().toUtc();
  return Credential(
    id: id,
    platform: 'P',
    username: 'u',
    password: 'p',
    rotationPolicyDays: policyDays,
    createdAtUtc: now.subtract(Duration(days: ageDays)),
    updatedAtUtc: now.subtract(Duration(days: ageDays)),
    lastChangedUtc: now.subtract(Duration(days: ageDays)),
  );
}

void main() {
  test('weekly re-invoke is idempotent: same due notified, same fresh cleared',
      () async {
    final notifier = RecordingNotifier();
    final service = ReminderService(notifier: notifier);
    final credentials = [
      _cred('due-1', policyDays: 90, ageDays: 100),
      _cred('fresh-1', policyDays: 365, ageDays: 10),
    ];

    final first = await service.process(
        credentials: credentials, nowUtc: DateTime.now().toUtc());
    expect(first.map((c) => c.id), ['due-1']);
    expect(notifier.notifiedIds, ['due-1']);
    expect(notifier.clearedIds, ['fresh-1']);

    notifier.notifiedIds.clear();
    notifier.clearedIds.clear();
    final second = await service.process(
        credentials: credentials, nowUtc: DateTime.now().toUtc());
    expect(second.map((c) => c.id), ['due-1']);
    expect(notifier.notifiedIds, ['due-1']);
    expect(notifier.clearedIds, ['fresh-1']);
  });
}
