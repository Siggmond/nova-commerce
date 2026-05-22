import 'dart:async';
import 'dart:convert';
import 'dart:io';

class _RpcClient {
  _RpcClient(this._ws) {
    _subscription = _ws.listen(_onMessage);
  }

  final WebSocket _ws;
  late final StreamSubscription<dynamic> _subscription;
  final Map<int, Completer<Map<String, dynamic>>> _pending =
      <int, Completer<Map<String, dynamic>>>{};
  int _nextId = 1;

  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, dynamic>? params,
  }) {
    final id = _nextId++;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;

    _ws.add(
      jsonEncode(<String, dynamic>{
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        if (params != null) 'params': params,
      }),
    );

    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutException('RPC timeout for $method');
      },
    );
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;
    final idAny = decoded['id'];
    if (idAny is! int) return;
    final completer = _pending.remove(idAny);
    if (completer == null) return;
    if (decoded['error'] != null) {
      completer.completeError(StateError('${decoded['error']}'));
      return;
    }
    final result = decoded['result'];
    if (result is Map<String, dynamic>) {
      completer.complete(result);
    } else {
      completer.complete(<String, dynamic>{'value': result});
    }
  }

  Future<void> close() async {
    await _subscription.cancel();
    await _ws.close();
  }
}

Future<void> _runAdb(List<String> args, {Duration? delayAfter}) async {
  final process = await Process.start('adb', args);
  final code = await process.exitCode;
  if (code != 0) {
    final stderr = await utf8.decodeStream(process.stderr);
    throw ProcessException(
      'adb',
      args,
      stderr,
      code,
    );
  }
  if (delayAfter != null) {
    await Future<void>.delayed(delayAfter);
  }
}

Future<String> _runAdbStdout(List<String> args) async {
  final result = await Process.run('adb', args);
  if (result.exitCode != 0) {
    throw ProcessException(
      'adb',
      args,
      '${result.stderr}',
      result.exitCode,
    );
  }
  return '${result.stdout}'.trim();
}

Future<void> _scrollFor({
  required String deviceId,
  required int x,
  required int yFrom,
  required int yTo,
  required Duration total,
}) async {
  final endAt = DateTime.now().add(total);
  while (DateTime.now().isBefore(endAt)) {
    await _runAdb(
      <String>[
        '-s',
        deviceId,
        'shell',
        'input',
        'swipe',
        '$x',
        '$yFrom',
        '$x',
        '$yTo',
        '300',
      ],
      delayAfter: const Duration(milliseconds: 500),
    );
  }
}

Map<String, int> _parseSize(String raw) {
  final match = RegExp(r'Physical size:\s*(\d+)x(\d+)').firstMatch(raw);
  if (match == null) {
    throw StateError('Unable to parse wm size: $raw');
  }
  return <String, int>{
    'width': int.parse(match.group(1)!),
    'height': int.parse(match.group(2)!),
  };
}

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    stderr.writeln(
      'Usage: dart run tool/profile_capture.dart <wsUri> <deviceId> <outputJson>',
    );
    exit(64);
  }

  final wsUri = Uri.parse(args[0]);
  final deviceId = args[1];
  final outputPath = args[2];

  stdout.writeln('Connecting to VM service: $wsUri');
  final ws = await WebSocket.connect(wsUri.toString());
  final rpc = _RpcClient(ws);

  try {
    await rpc.call('setVMTimelineFlags', params: <String, dynamic>{
      'recordedStreams': <String>[
        'Embedder',
      ],
    });
    await rpc.call('clearVMTimeline');
    final start = await rpc.call('getVMTimelineMicros');
    final startMicros = (start['timestamp'] as num?)?.toInt();
    if (startMicros == null) {
      throw StateError('Missing start timestamp from getVMTimelineMicros.');
    }
    stdout.writeln('Timeline start micros: $startMicros');

    final sizeRaw = await _runAdbStdout(<String>[
      '-s',
      deviceId,
      'shell',
      'wm',
      'size',
    ]);
    final model = await _runAdbStdout(<String>[
      '-s',
      deviceId,
      'shell',
      'getprop',
      'ro.product.model',
    ]);
    stdout.writeln('Detected Android device model: $model');
    if (!model.toLowerCase().contains('a34')) {
      stdout.writeln(
        'WARNING: This capture is not on Samsung A34. '
        'Use physical A34 measurements for release gating.',
      );
    }
    final size = _parseSize(sizeRaw);
    final width = size['width']!;
    final height = size['height']!;

    final navY = height - 70;
    int tabX(int index, int tabCount) {
      final bucket = width / tabCount;
      return (bucket * (index + 0.5)).round();
    }

    final homeX = tabX(0, 6);
    final offersX = tabX(3, 6);
    final accountX = tabX(5, 6);
    final scrollX = (width * 0.5).round();
    final scrollFromY = (height * 0.82).round();
    final scrollToY = (height * 0.34).round();

    // Ensure we begin from Home.
    await _runAdb(
      <String>[
        '-s',
        deviceId,
        'shell',
        'input',
        'tap',
        '$homeX',
        '$navY',
      ],
      delayAfter: const Duration(milliseconds: 800),
    );

    stdout.writeln('Phase 1: Home scroll 10s');
    await _scrollFor(
      deviceId: deviceId,
      x: scrollX,
      yFrom: scrollFromY,
      yTo: scrollToY,
      total: const Duration(seconds: 10),
    );

    stdout.writeln('Phase 2: Switch to Offers + scroll 10s');
    await _runAdb(
      <String>[
        '-s',
        deviceId,
        'shell',
        'input',
        'tap',
        '$offersX',
        '$navY',
      ],
      delayAfter: const Duration(seconds: 1),
    );
    await _scrollFor(
      deviceId: deviceId,
      x: scrollX,
      yFrom: scrollFromY,
      yTo: scrollToY,
      total: const Duration(seconds: 10),
    );

    stdout.writeln('Phase 3: Switch to Account + scroll 12s');
    await _runAdb(
      <String>[
        '-s',
        deviceId,
        'shell',
        'input',
        'tap',
        '$accountX',
        '$navY',
      ],
      delayAfter: const Duration(seconds: 1),
    );
    await _scrollFor(
      deviceId: deviceId,
      x: scrollX,
      yFrom: scrollFromY,
      yTo: scrollToY,
      total: const Duration(seconds: 12),
    );

    stdout.writeln('Phase 4: Leave Account -> Home + scroll 10s');
    await _runAdb(
      <String>[
        '-s',
        deviceId,
        'shell',
        'input',
        'tap',
        '$homeX',
        '$navY',
      ],
      delayAfter: const Duration(milliseconds: 800),
    );
    await _scrollFor(
      deviceId: deviceId,
      x: scrollX,
      yFrom: scrollFromY,
      yTo: scrollToY,
      total: const Duration(seconds: 10),
    );

    final end = await rpc.call('getVMTimelineMicros');
    final endMicros = (end['timestamp'] as num?)?.toInt();
    if (endMicros == null || endMicros <= startMicros) {
      throw StateError('Invalid end timestamp from getVMTimelineMicros.');
    }

    final timeline = await rpc.call(
      'getVMTimeline',
      params: <String, dynamic>{
        'timeOriginMicros': startMicros,
        'timeExtentMicros': endMicros - startMicros,
      },
    );
    final outFile = File(outputPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(timeline),
    );
    stdout.writeln(
      'Saved timeline JSON: ${outFile.path} (${endMicros - startMicros} micros)',
    );
  } finally {
    await rpc.close();
  }
}
