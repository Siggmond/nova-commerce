abstract class Telemetry {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  });

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  });
}

class NoopTelemetry implements Telemetry {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {}
}
