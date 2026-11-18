/// Converts a package's validity (e.g. 7 + "Days", 1 + "Month") into days.
/// Returns null when the value or unit is missing or not recognised, so the
/// package is left out of cost-per-day comparisons instead of being guessed.
double? validityInDays(num? value, String? period) {
  if (value == null || value <= 0) return null;
  final p = (period ?? '').trim().toLowerCase();
  if (p.contains('hour')) return value / 24;
  if (p.contains('day') || p.startsWith('dai')) return value.toDouble();
  if (p.contains('week')) return value * 7.0;
  if (p.contains('month')) return value * 30.0;
  if (p.contains('year') || p.contains('annual')) return value * 365.0;
  return null;
}
