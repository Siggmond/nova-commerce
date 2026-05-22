import 'dart:developer' as developer;
import 'dart:io';

import 'memory_sample_model.dart';

Future<PerfMemorySnapshot> samplePerfMemory(String label) async {
  try {
    final rssMb = ProcessInfo.currentRss / (1024 * 1024);
    var source = 'process_rss';
    String? note;

    try {
      final serviceInfo = await developer.Service.getInfo();
      if (serviceInfo.serverUri != null) {
        source = 'process_rss_with_vm_service';
      } else {
        note = 'VM Service heap metrics unavailable; using process RSS.';
      }
    } catch (_) {
      note = 'VM Service unavailable; using process RSS.';
    }

    return PerfMemorySnapshot(
      label: label,
      megabytes: rssMb,
      source: source,
      note: note,
    );
  } catch (_) {
    return PerfMemorySnapshot(
      label: label,
      megabytes: null,
      source: 'unavailable',
      note: 'Failed to read process RSS.',
    );
  }
}
