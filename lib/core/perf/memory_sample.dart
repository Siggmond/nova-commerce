import 'memory_sample_model.dart';
import 'memory_sample_stub.dart'
    if (dart.library.io) 'memory_sample_io.dart'
    as impl;

Future<PerfMemorySnapshot> samplePerfMemory(String label) {
  return impl.samplePerfMemory(label);
}
