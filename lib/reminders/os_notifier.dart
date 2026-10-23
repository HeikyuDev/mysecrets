import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../vault/credential.dart';
import 'reminder_service.dart';

/// OS notification adapter over flutter_local_notifications.
/// One notification per credential, id derived from the credential id so
/// re-running ReminderService stays idempotent (same id overwrites).
class OsNotifier implements NotifierPort {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'rotation_reminders';

  Future<void> initialize() async {
    if (_initialized) return;
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: init);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  int _idFor(String credentialId) {
    final signed = credentialId.hashCode;
    return signed & 0x7fffffff;
  }

  @override
  Future<void> notify(Credential credential, int daysOverdue) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Rotation reminders',
        channelDescription:
            'Reminds you when a stored password is due for rotation',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      id: _idFor(credential.id),
      title: 'Rotate your ${credential.platform} password',
      body: daysOverdue > 0
          ? 'It is $daysOverdue days past its rotation policy.'
          : 'Its rotation policy is due today.',
      notificationDetails: details,
      payload: credential.id,
    );
  }

  @override
  Future<void> clearFor(String credentialId) async {
    await _plugin.cancel(id: _idFor(credentialId));
  }
}
