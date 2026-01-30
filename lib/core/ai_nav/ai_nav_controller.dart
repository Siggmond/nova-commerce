import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'ai_nav_intent.dart';
import 'ai_nav_model_runner.dart';
import 'ai_nav_suggestion.dart';

class AiNavController extends StateNotifier<AiNavSuggestion?> {
  AiNavController({
    required AiNavRunner modelRunner,
    this.minConfidence = 0.35,
    this.highConfidence = 0.60,
    this.minMargin = 0.10,
    this.requiredConsecutive = 2,
    this.defaultCooldown = const Duration(milliseconds: 800),
    DateTime Function()? now,
  })  : _modelRunner = modelRunner,
        _now = (now ?? DateTime.now),
        super(null);

  final AiNavRunner _modelRunner;
  final DateTime Function() _now;

  final double minConfidence;

  final double highConfidence;

  final double minMargin;

  final int requiredConsecutive;

  final Duration defaultCooldown;

  List<double>? _lastFeatures;
  bool _inferenceInFlight = false;
  bool _rerunAfterFlight = false;

  bool _suppressed = false;
  DateTime? _cooldownUntil;
  bool _cooldownScheduled = false;
  Timer? _cooldownTimer;
  int _generation = 0;

  AiNavIntent? _candidateIntent;
  int _candidateCount = 0;

  void disposeController() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _modelRunner.dispose();
  }

  void consumeSuggestionAndCooldown({Duration? cooldown}) {
    _generation++;
    _resetCandidate();
    state = null;

    final d = cooldown ?? defaultCooldown;
    _cooldownUntil = _now().add(d);
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _scheduleAfterCooldownIfNeeded();
  }

  void setSuppressed(bool suppressed) {
    if (_suppressed == suppressed) return;
    _suppressed = suppressed;

    _generation++;
    _resetCandidate();

    if (_suppressed) {
      state = null;
      return;
    }

    _scheduleInference();
  }

  void updateFeatures(List<double> features) {
    if (features.length != 5) return;

    final last = _lastFeatures;
    if (last != null && _sameVector(last, features)) {
      return;
    }

    _lastFeatures = List<double>.unmodifiable(features);
    if (_suppressed) return;
    _scheduleInference();
  }

  void _scheduleInference() {
    if (_suppressed) return;
    if (_isInCooldown) {
      _scheduleAfterCooldownIfNeeded();
      return;
    }
    if (_inferenceInFlight) {
      _rerunAfterFlight = true;
      return;
    }

    _inferenceInFlight = true;
    final generation = _generation;

    Future<void>(() async {
      try {
        await _modelRunner.ensureLoaded();
        final features = _lastFeatures;
        if (features == null) return;

        final raw = _modelRunner.run(features: features);
        final thresholded = _applyThresholds(raw);
        final next = _applyStability(thresholded);

        if (generation != _generation) return;
        if (_suppressed || _isInCooldown) return;

        if (!_sameSuggestion(state, next)) {
          state = next;
        }
      } catch (_) {
        // The AI layer must never crash the app (or tests). If model loading
        // fails or native binaries are missing, we simply emit no suggestion.
        if (state != null) {
          state = null;
        }
      } finally {
        _inferenceInFlight = false;
        if (_rerunAfterFlight) {
          _rerunAfterFlight = false;
          _scheduleInference();
        }
      }
    });
  }

  AiNavSuggestion? _applyThresholds(AiNavSuggestion suggestion) {
    // `idle` must never trigger UI action.
    if (suggestion.intent == AiNavIntent.idle) return null;

    if (suggestion.confidence < minConfidence) return null;

    final bestIndex = suggestion.intent.index;
    final runnerUp = AiNavModelRunner.secondBest(
      suggestion.probabilities,
      bestIndex,
    );

    if ((suggestion.confidence - runnerUp) < minMargin) return null;

    return suggestion;
  }

  AiNavSuggestion? _applyStability(AiNavSuggestion? suggestion) {
    if (suggestion == null) {
      _resetCandidate();
      return null;
    }

    final intent = suggestion.intent;
    if (intent == AiNavIntent.idle) {
      _resetCandidate();
      return null;
    }

    if (_candidateIntent == intent) {
      _candidateCount += 1;
    } else {
      _candidateIntent = intent;
      _candidateCount = 1;
    }

    if (suggestion.confidence >= highConfidence) {
      return suggestion;
    }

    if (_candidateCount >= requiredConsecutive) {
      return suggestion;
    }

    return null;
  }

  bool get _isInCooldown {
    final until = _cooldownUntil;
    if (until == null) return false;
    return _now().isBefore(until);
  }

  void _scheduleAfterCooldownIfNeeded() {
    if (_cooldownScheduled) return;
    final until = _cooldownUntil;
    if (until == null) return;

    final remaining = until.difference(_now());
    if (remaining <= Duration.zero) {
      _cooldownScheduled = false;
      _cooldownUntil = null;
      _scheduleInference();
      return;
    }

    _cooldownScheduled = true;
    _cooldownTimer = Timer(remaining, () {
      _cooldownScheduled = false;
      if (_isInCooldown) {
        _scheduleAfterCooldownIfNeeded();
        return;
      }
      _cooldownUntil = null;
      _cooldownTimer = null;
      _scheduleInference();
    });
  }

  void _resetCandidate() {
    _candidateIntent = null;
    _candidateCount = 0;
  }

  static bool _sameVector(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameSuggestion(AiNavSuggestion? a, AiNavSuggestion? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    return a.intent == b.intent && a.confidence == b.confidence;
  }
}
