import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:nova_commerce/core/ai_nav/ai_nav_controller.dart';
import 'package:nova_commerce/core/ai_nav/ai_nav_intent.dart';
import 'package:nova_commerce/core/ai_nav/ai_nav_model_runner.dart';
import 'package:nova_commerce/core/ai_nav/ai_nav_suggestion.dart';

class _FakeRunner implements AiNavRunner {
  _FakeRunner(this._suggestion);

  AiNavSuggestion _suggestion;

  set suggestion(AiNavSuggestion s) => _suggestion = s;

  @override
  Future<void> ensureLoaded() async {}

  @override
  AiNavSuggestion run({required List<double> features}) => _suggestion;

  @override
  void dispose() {}
}

AiNavSuggestion _s(
  AiNavIntent intent,
  List<double> probs,
) {
  return AiNavSuggestion(
    intent: intent,
    confidence: probs[intent.index],
    probabilities: probs,
  );
}

void main() {
  test('idle intent yields no suggestion (null state)', () async {
    final runner = _FakeRunner(_s(
      AiNavIntent.idle,
      [0.0, 0.0, 0.0, 0.0, 0.0, 1.0],
    ));
    final controller = AiNavController(modelRunner: runner);
    addTearDown(controller.disposeController);

    controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.state, isNull);
  });

  test('low confidence yields no suggestion (null state)', () async {
    final runner = _FakeRunner(_s(
      AiNavIntent.home,
      // best = 0.30 < 0.35
      [0.30, 0.20, 0.15, 0.15, 0.10, 0.10],
    ));
    final controller = AiNavController(modelRunner: runner, minConfidence: 0.35);
    addTearDown(controller.disposeController);

    controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.state, isNull);
  });

  test('insufficient margin yields no suggestion (null state)', () async {
    final runner = _FakeRunner(_s(
      AiNavIntent.cart,
      // best = 0.50, runner-up = 0.46, margin = 0.04 < 0.10
      [0.04, 0.04, 0.46, 0.50, 0.04, 0.0],
    ));
    final controller = AiNavController(modelRunner: runner, minConfidence: 0.35, minMargin: 0.10);
    addTearDown(controller.disposeController);

    controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.state, isNull);
  });

  test('mid confidence requires two consecutive identical intents before suggesting',
      () async {
    final runner = _FakeRunner(_s(
      AiNavIntent.trends,
      // confidence = 0.50 (>=0.35 and <0.60) so should require streak=2
      [0.05, 0.10, 0.50, 0.20, 0.10, 0.05],
    ));
    final controller = AiNavController(modelRunner: runner, minConfidence: 0.35, minMargin: 0.10);
    addTearDown(controller.disposeController);

    controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    // first hit: no suggestion
    expect(controller.state, isNull);

    // second hit with different features (forces another inference)
    controller.updateFeatures(const [0, 0, 0, 0, 1].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.state, isNotNull);
    expect(controller.state!.intent, AiNavIntent.trends);
  });

  test('high confidence overrides streak requirement', () async {
    final runner = _FakeRunner(_s(
      AiNavIntent.trends,
      // best = 0.82, runner-up = 0.10
      [0.03, 0.10, 0.82, 0.03, 0.01, 0.01],
    ));
    final controller = AiNavController(modelRunner: runner);
    addTearDown(controller.disposeController);

    controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.state, isNotNull);
    expect(controller.state!.intent, AiNavIntent.trends);
  });

  test('consumeSuggestionAndCooldown clears suggestion and blocks new ones briefly',
      () {
    fakeAsync((async) {
      var now = DateTime(2026, 1, 1, 10, 0, 0);
      DateTime clock() => now;

      final runner = _FakeRunner(_s(
        AiNavIntent.home,
        [0.82, 0.05, 0.05, 0.03, 0.03, 0.02],
      ));
      final controller = AiNavController(
        modelRunner: runner,
        now: clock,
        defaultCooldown: const Duration(milliseconds: 800),
      );
      addTearDown(controller.disposeController);

      controller.updateFeatures(const [0, 0, 0, 0, 0].map((e) => e.toDouble()).toList());
      async.elapse(Duration.zero);
      async.flushMicrotasks();
      expect(controller.state, isNotNull);

      controller.consumeSuggestionAndCooldown();
      async.flushMicrotasks();
      expect(controller.state, isNull);

      // new features while in cooldown should not surface suggestion yet
      controller.updateFeatures(const [0, 0, 0, 0, 1].map((e) => e.toDouble()).toList());
      async.elapse(Duration.zero);
      async.flushMicrotasks();
      expect(controller.state, isNull);

      now = now.add(const Duration(milliseconds: 799));
      async.elapse(const Duration(milliseconds: 799));
      async.flushMicrotasks();
      expect(controller.state, isNull);

      now = now.add(const Duration(milliseconds: 2));
      async.elapse(const Duration(milliseconds: 2));
      async.flushMicrotasks();

      expect(controller.state, isNotNull);
      expect(controller.state!.intent, AiNavIntent.home);
    });
  });
}
