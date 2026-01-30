import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'ai_nav_intent.dart';
import 'ai_nav_suggestion.dart';

abstract class AiNavRunner {
  Future<void> ensureLoaded();
  AiNavSuggestion run({required List<double> features});
  void dispose();
}

class AiNavModelRunner implements AiNavRunner {
  AiNavModelRunner({
    required this.assetPath,
  });

  final String assetPath;

  Interpreter? _interpreter;
  bool _loadFailed = false;
  Object? _loadError;

  @override
  Future<void> ensureLoaded() async {
    if (_interpreter != null) return;
    if (_loadFailed) return;

    try {
      final data = await rootBundle.load(assetPath);
      _interpreter = Interpreter.fromBuffer(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } catch (e) {
      // `tflite_flutter` requires native binaries. In some environments
      // (notably Flutter widget tests on desktop), those binaries may not be
      // present. We fail gracefully so the app/tests can still run.
      _loadFailed = true;
      _loadError = e;
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  @override
  AiNavSuggestion run({required List<double> features}) {
    if (features.length != 5) {
      throw ArgumentError('Expected 5 float features, got ${features.length}.');
    }

    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Model not loaded. Call ensureLoaded() first. Error=$_loadError');
    }

    // Batch size = 1.
    final input = <List<double>>[features];
    final output = List<List<double>>.generate(
      1,
      (_) => List<double>.filled(6, 0.0),
      growable: false,
    );

    interpreter.run(input, output);

    final probs = output.first;
    final normalized = _normalizeProbabilities(probs);

    final bestIndex = _argMax(normalized);
    final intent = AiNavIntent.values[bestIndex];
    final confidence = normalized[bestIndex];

    return AiNavSuggestion(
      intent: intent,
      confidence: confidence,
      probabilities: normalized,
    );
  }

  static List<double> _normalizeProbabilities(List<double> probs) {
    // The model is described as returning probabilities, but we still guard
    // against tiny numeric drift.
    final sum = probs.fold<double>(0.0, (s, v) => s + v);
    if (sum <= 0) {
      return List<double>.filled(probs.length, 0.0, growable: false);
    }
    return probs.map((v) => (v / sum).clamp(0.0, 1.0)).toList(growable: false);
  }

  static int _argMax(List<double> values) {
    var bestIndex = 0;
    var bestValue = -double.infinity;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v > bestValue) {
        bestValue = v;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static double secondBest(List<double> values, int bestIndex) {
    var best = -double.infinity;
    for (var i = 0; i < values.length; i++) {
      if (i == bestIndex) continue;
      best = max(best, values[i]);
    }
    return best;
  }
}
