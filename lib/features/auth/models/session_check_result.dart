class SessionCheckResult {
  const SessionCheckResult({
    required this.isAuthenticated,
    this.showOfflineOption = false,
  });

  final bool isAuthenticated;
  final bool showOfflineOption;

  factory SessionCheckResult.authenticated() {
    return const SessionCheckResult(isAuthenticated: true);
  }

  factory SessionCheckResult.unauthenticated() {
    return const SessionCheckResult(isAuthenticated: false);
  }

  factory SessionCheckResult.offlineAvailable() {
    return const SessionCheckResult(
      isAuthenticated: false,
      showOfflineOption: true,
    );
  }
}
