import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_nav_controller.dart';
import 'ai_nav_model_runner.dart';
import 'ai_nav_suggestion.dart';

final aiNavControllerProvider =
    StateNotifierProvider<AiNavController, AiNavSuggestion?>((ref) {
      final runner = AiNavModelRunner(
        // Must match `pubspec.yaml`.
        assetPath: 'assets/models/ai_nav_model_quant.tflite',
      );

      final controller = AiNavController(modelRunner: runner);
      ref.onDispose(controller.disposeController);

      return controller;
    });
