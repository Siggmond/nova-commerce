import 'memory_sample_model.dart';

Future<PerfMemorySnapshot> samplePerfMemory(String label) async {
  return PerfMemorySnapshot(
    label: label,
    megabytes: null,
    source: 'unavailable',
    note: 'Memory sampling requires a dart:io runtime.',
  );
}
