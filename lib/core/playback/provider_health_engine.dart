class ProviderHealthEngine {
  ProviderHealthEngine({this.failureThreshold = 3, this.cooldown = const Duration(seconds: 30)});
  final int failureThreshold;
  final Duration cooldown;
  final Map<String, int> _failures = {};
  final Map<String, DateTime> _openUntil = {};

  bool canAttempt(String providerId) {
    final until = _openUntil[providerId];
    if (until == null) return true;
    if (DateTime.now().isAfter(until)) { _openUntil.remove(providerId); return true; }
    return false;
  }

  void recordFailure(String providerId) {
    final count = (_failures[providerId] ?? 0) + 1;
    _failures[providerId] = count;
    if (count >= failureThreshold) _openUntil[providerId] = DateTime.now().add(cooldown);
  }

  void recordSuccess(String providerId) {
    _failures.remove(providerId);
    _openUntil.remove(providerId);
  }
}
