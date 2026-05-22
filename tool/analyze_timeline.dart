import 'dart:convert';
import 'dart:io';

class _Span {
  _Span({
    required this.name,
    required this.startUs,
    required this.durUs,
    required this.pid,
    required this.tid,
    required this.threadName,
  });

  final String name;
  final int startUs;
  final int durUs;
  final int pid;
  final int tid;
  final String threadName;

  int get endUs => startUs + durUs;
}

class _PhaseStats {
  _PhaseStats({required this.name, required this.startUs, required this.endUs});

  final String name;
  final int startUs;
  final int endUs;

  int uiSlowCount = 0;
  int rasterSlowCount = 0;
  int uiTotalUs = 0;
  int rasterTotalUs = 0;
  int uiMaxUs = 0;
  int rasterMaxUs = 0;

  final Map<String, int> eventTotalByName = <String, int>{};
  final Map<String, int> eventCountByName = <String, int>{};
  final Map<String, int> markerCount = <String, int>{};

  void add(_Span span) {
    final isUi = span.threadName.contains('.ui');
    final isRaster = span.threadName.contains('.raster');
    if (isUi) {
      uiTotalUs += span.durUs;
      if (span.durUs > uiMaxUs) uiMaxUs = span.durUs;
      if (span.durUs >= 16000) uiSlowCount++;
    }
    if (isRaster) {
      rasterTotalUs += span.durUs;
      if (span.durUs > rasterMaxUs) rasterMaxUs = span.durUs;
      if (span.durUs >= 16000) rasterSlowCount++;
    }
    if (isUi || isRaster) {
      eventTotalByName.update(
        span.name,
        (v) => v + span.durUs,
        ifAbsent: () => span.durUs,
      );
      eventCountByName.update(span.name, (v) => v + 1, ifAbsent: () => 1);
    }

    const markers = <String>[
      'GPURasterizer::Draw',
      'Picture::Rasterize',
      'Canvas::drawImage',
      'OpacityLayer',
      'PhysicalShapeLayer',
      'ClipRRect',
      'BackdropFilterLayer',
      'Shader',
      'Pipeline',
      'ReclaimResources',
      'CheckFenceStatus',
    ];
    for (final marker in markers) {
      if (span.name.contains(marker)) {
        markerCount.update(marker, (v) => v + 1, ifAbsent: () => 1);
      }
    }
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/analyze_timeline.dart <timelineJsonPath>',
    );
    exit(64);
  }

  final timelinePath = args[0];
  final data =
      jsonDecode(await File(timelinePath).readAsString())
          as Map<String, dynamic>;
  final traceEvents = (data['traceEvents'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  final threadNames = <String, String>{};
  int minTs = 1 << 62;
  int maxTs = 0;
  for (final e in traceEvents) {
    final ts = (e['ts'] as num?)?.toInt();
    if (ts != null) {
      if (ts < minTs) minTs = ts;
      if (ts > maxTs) maxTs = ts;
    }
    if (e['ph'] == 'M' && e['name'] == 'thread_name') {
      final pid = (e['pid'] as num?)?.toInt();
      final tid = (e['tid'] as num?)?.toInt();
      final argsMap = e['args'];
      if (pid == null || tid == null || argsMap is! Map<String, dynamic>)
        continue;
      final name = argsMap['name'];
      if (name is String) {
        threadNames['$pid:$tid'] = name;
      }
    }
  }

  final stacks = <String, List<Map<String, dynamic>>>{};
  final spans = <_Span>[];

  for (final e in traceEvents) {
    final ph = e['ph'];
    final pid = (e['pid'] as num?)?.toInt();
    final tid = (e['tid'] as num?)?.toInt();
    final ts = (e['ts'] as num?)?.toInt();
    final name = e['name']?.toString();
    if (pid == null || tid == null || ts == null || name == null) continue;
    final key = '$pid:$tid';
    if (ph == 'B') {
      stacks.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(e);
    } else if (ph == 'E') {
      final stack = stacks[key];
      if (stack == null || stack.isEmpty) continue;
      final start = stack.removeLast();
      final startTs = (start['ts'] as num).toInt();
      final startName = start['name']?.toString() ?? '';
      final dur = ts - startTs;
      if (dur <= 0) continue;
      spans.add(
        _Span(
          name: startName,
          startUs: startTs,
          durUs: dur,
          pid: pid,
          tid: tid,
          threadName: threadNames[key] ?? key,
        ),
      );
    }
  }

  final phase1End = minTs + 10800000; // Home tap/setup + ~10s scroll
  final phase2End = phase1End + 11000000; // Offers enter + ~10s scroll
  final phase3End = phase2End + 13000000; // Account enter + ~12s scroll

  final phases = <_PhaseStats>[
    _PhaseStats(name: 'home_initial', startUs: minTs, endUs: phase1End),
    _PhaseStats(name: 'offers', startUs: phase1End, endUs: phase2End),
    _PhaseStats(name: 'account', startUs: phase2End, endUs: phase3End),
    _PhaseStats(name: 'home_after_account', startUs: phase3End, endUs: maxTs),
  ];

  _PhaseStats phaseFor(_Span span) {
    for (final phase in phases) {
      if (span.startUs >= phase.startUs && span.startUs < phase.endUs) {
        return phase;
      }
    }
    return phases.last;
  }

  for (final span in spans) {
    phaseFor(span).add(span);
  }

  final slowUiOrRaster =
      spans
          .where(
            (s) =>
                (s.threadName.contains('.ui') ||
                    s.threadName.contains('.raster')) &&
                s.durUs >= 16000,
          )
          .toList()
        ..sort((a, b) => b.durUs.compareTo(a.durUs));

  final topSlow = slowUiOrRaster.take(25).map((s) {
    return <String, dynamic>{
      'name': s.name,
      'dur_us': s.durUs,
      'thread': s.threadName,
      'start_us': s.startUs,
    };
  }).toList();

  final out = <String, dynamic>{
    'timeline_path': timelinePath,
    'time_range_us': <String, int>{
      'start': minTs,
      'end': maxTs,
      'extent': maxTs - minTs,
    },
    'phase_boundaries_us': <String, int>{
      'home_initial_end': phase1End,
      'offers_end': phase2End,
      'account_end': phase3End,
    },
    'phases': phases
        .map(
          (p) => <String, dynamic>{
            'name': p.name,
            'start_us': p.startUs,
            'end_us': p.endUs,
            'ui_total_us': p.uiTotalUs,
            'raster_total_us': p.rasterTotalUs,
            'ui_max_us': p.uiMaxUs,
            'raster_max_us': p.rasterMaxUs,
            'ui_slow_events_ge_16ms': p.uiSlowCount,
            'raster_slow_events_ge_16ms': p.rasterSlowCount,
            'top_events_by_total_us':
                (p.eventTotalByName.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value)))
                    .take(20)
                    .map(
                      (e) => <String, dynamic>{
                        'name': e.key,
                        'total_us': e.value,
                        'count': p.eventCountByName[e.key] ?? 0,
                      },
                    )
                    .toList(),
            'marker_counts': p.markerCount,
          },
        )
        .toList(),
    'top_slow_ui_or_raster_events_ge_16ms': topSlow,
  };

  final outPath = timelinePath.replaceAll('.json', '.summary.json');
  await File(
    outPath,
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(out));
  stdout.writeln('Wrote summary: $outPath');
}
