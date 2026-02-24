import 'dart:math' as math;

class PaymentAmountCalculator {
  const PaymentAmountCalculator();

  double computeAddonByPercent({
    required double base,
    required int percent,
    required bool enabled,
  }) {
    if (!enabled) return 0;
    if (base <= 0) return 0;
    if (percent <= 0) return 0;
    return base * percent / 100.0;
  }

  double clampAmount(double value) {
    if (value.isNaN || value.isInfinite) return 0;
    return math.max(0, value);
  }
}