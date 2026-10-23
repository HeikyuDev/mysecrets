import 'dart:convert';

class Credential {
  final String id;
  final String platform;
  final String username;
  final String password;
  final String? notes;
  final int? rotationPolicyDays;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime lastChangedUtc;

  Credential({
    required this.id,
    required this.platform,
    required this.username,
    required this.password,
    this.notes,
    this.rotationPolicyDays,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.lastChangedUtc,
  });

  Credential copyWith({
    String? platform,
    String? username,
    String? password,
    String? notes,
    int? rotationPolicyDays,
  }) =>
      Credential(
        id: id,
        platform: platform ?? this.platform,
        username: username ?? this.username,
        password: password ?? this.password,
        notes: notes ?? this.notes,
        rotationPolicyDays: rotationPolicyDays ?? this.rotationPolicyDays,
        createdAtUtc: createdAtUtc,
        updatedAtUtc: updatedAtUtc,
        lastChangedUtc: lastChangedUtc,
      );
  String toJson() => jsonEncode({
        'id': id,
        'platform': platform,
        'username': username,
        'password': password,
        if (notes != null) 'notes': notes,
        if (rotationPolicyDays != null)
          'rotationPolicyDays': rotationPolicyDays,
        'createdAt': createdAtUtc.toIso8601String(),
        'updatedAt': updatedAtUtc.toIso8601String(),
        'lastChangedAt': lastChangedUtc.toIso8601String(),
      });

  static Credential fromJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Credential(
      id: map['id'] as String,
      platform: map['platform'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      notes: map['notes'] as String?,
      rotationPolicyDays: map['rotationPolicyDays'] as int?,
      createdAtUtc: DateTime.parse(map['createdAt'] as String).toUtc(),
      updatedAtUtc:
          DateTime.parse(map['updatedAt'] as String).toUtc(),
      lastChangedUtc:
          DateTime.parse(map['lastChangedAt'] as String).toUtc(),
    );
  }
}
