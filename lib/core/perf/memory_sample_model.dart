class PerfMemorySnapshot {
  const PerfMemorySnapshot({
    required this.label,
    required this.megabytes,
    required this.source,
    this.note,
  });

  final String label;
  final double? megabytes;
  final String source;
  final String? note;
}
