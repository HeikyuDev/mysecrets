import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/reminders/reminder_service.dart';
import 'package:mysecrets/vault/credential.dart';

class FakeNotifier implements NotifierPort {
  final List<String> notifiedIds = [];
  final List<String> clearedIds = [];

  @override
  Future<void> notify(Credential credential, int daysOverdue) async {
    notifiedIds.add(credential.id);
  }

  @override
  Future<void> clearFor(String credentialId) async {
    clearedIds.add(credentialId);
  }
}

String _id(int seed) {
  final rnd = Random(seed);
  return 'c${rnd.nextInt(100000)}-${rnd.nextInt(100000)}';
}

DateTime _utcNow() => DateTime.now().toUtc();

void main() {
  late FakeNotifier notifier;
  late ReminderService service;

  setUp(() {
    notifier = FakeNotifier();
    service = ReminderService(notifier: notifier);
  });

  List<Credential> creds(int duePolicyDays, int ageDays, {String? id}) => [
        Credential(
          id: id ?? _id(ageDays * 31 + (duePolicyDays ~/ 10)),
          platform: 'P',
          username: 'u',
          password: 'p',
          rotationPolicyDays: duePolicyDays,
          createdAtUtc: _utcNow().subtract(Duration(days: ageDays)),
          updatedAtUtc: _utcNow().subtract(Duration(days: ageDays)),
          lastChangedUtc: _utcNow().subtract(Duration(days: ageDays)),
        )
      ];

  test('posts notifications only for due credentials', () async {
    final due = creds(90, 100, id: 'due-1');
    final fresh = creds(365, 10, id: 'fresh-1');
    final none = creds(90, 5, id: 'none-1');
    final result = await service.process(
        credentials: [...due, ...fresh, ...none], nowUtc: _utcNow());
    expect(notifier.notifiedIds, ['due-1']);
    expect(result, hasLength(1));
    expect(notifier.clearedIds, containsAll(['fresh-1', 'none-1']));
  });

  test('no policies means empty due set', () async {
    final c = Credential(
      id: 'x',
      platform: 'P',
      username: 'u',
      password: 'p',
      rotationPolicyDays: null,
      createdAtUtc: _utcNow(),
      updatedAtUtc: _utcNow(),
      lastChangedUtc: _utcNow().subtract(const Duration(days: 1000)),
    );
    final result = await service.process(credentials: [c], nowUtc: _utcNow());
    expect(result, isEmpty);
    expect(notifier.notifiedIds, isEmpty);
  });
}
