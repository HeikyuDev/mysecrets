import 'package:mysecrets/vault/credential.dart';
import 'reminder_service.dart';

/// No-op NotifierPort: used as default so controller wiring never crashes
/// when the OS adapter is unavailable (tests, unsupported platforms).
class NullNotifier implements NotifierPort {
  @override
  Future<void> notify(Credential credential, int daysOverdue) async {}

  @override
  Future<void> clearFor(String credentialId) async {}
}
