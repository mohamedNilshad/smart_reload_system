/// Currency symbol used in suggestions, prompts and UI.
const kPlanCurrency = 'Rs. ';

/// 12500 -> "Rs. 12,500", 99.5 -> "Rs. 99.50"
String moneyText(double value, {String currency = kPlanCurrency}) {
  final isWhole = value == value.roundToDouble();
  final fixed = value.abs().toStringAsFixed(isWhole ? 0 : 2);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final sign = value < 0 ? '-' : '';
  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  return '$sign$currency$grouped$decimals';
}
