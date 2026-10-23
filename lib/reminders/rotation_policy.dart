import '../vault/credential.dart';

/// Pure due-rotation computation, no I/O, fully unit-testable.
class RotationPolicy {
  static const int defaultDays = 180;
  static const List<int> presets = [90, 180, 365];

  RotationPolicy._();

  static bool isDue({
    required DateTime lastChangedUtc,
    required int? policyDays,
    required DateTime nowUtc,
  }) {
    if (policyDays == null) return false;
    if (policyDays <= 0) {
      throw ArgumentError.value(policyDays, 'policyDays', 'must be positive');
    }
    return nowUtc.difference(lastChangedUtc).inDays >= policyDays;
  }

  static int daysOverdue({
    required DateTime lastChangedUtc,
    required int? policyDays,
    required DateTime nowUtc,
  }) {
    if (!isDue(
        lastChangedUtc: lastChangedUtc,
        policyDays: policyDays,
        nowUtc: nowUtc)) {
      return 0;
    }
    return nowUtc.difference(lastChangedUtc).inDays - policyDays!;
  }

  /// Builds the subset of [credentials] that are due. For UI badges.
  static List<Credential> dueFrom(
    List<Credential> credentials,
    Map<String, int?> policiesById,
    DateTime nowUtc,
  ) {
    return credentials
        .where((c) => isDue(
              lastChangedUtc: c.lastChangedUtc,
              policyDays: policiesById[c.id],
              nowUtc: nowUtc,
            ))
        .toList();
  }
}