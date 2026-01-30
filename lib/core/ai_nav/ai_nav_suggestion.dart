import 'ai_nav_intent.dart';

class AiNavSuggestion {
  const AiNavSuggestion({
    required this.intent,
    required this.confidence,
    required this.probabilities,
  });

  final AiNavIntent intent;
  final double confidence;

  final List<double> probabilities;
}
