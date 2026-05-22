import 'app/bootstrap.dart';
import 'app/main_common.dart';
import 'core/perf/perf_markers.dart';

Future<void> main() async {
  PerfMarkers.appStart();
  final telemetry = await bootstrap();
  if (telemetry == null) return;
  mainCommon(telemetry);
}
