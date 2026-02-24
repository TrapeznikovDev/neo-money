import 'package:equatable/equatable.dart';

class PlannedPurchase extends Equatable {
  final String title;
  final int months;
  final int cost;
  final int savings;

  const PlannedPurchase({
    required this.title,
    required this.months,
    required this.cost,
    required this.savings,
  });

  int get remaining => (cost - savings) < 0 ? 0 : (cost - savings);

  factory PlannedPurchase.fromJson(Map<String, dynamic> json) {
    return PlannedPurchase(
      title: json['title'] as String? ?? '',
      months: json['months'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      savings: json['savings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'months': months,
      'cost': cost,
      'savings': savings,
    };
  }

  PlannedPurchase copyWith({
    String? title,
    int? months,
    int? cost,
    int? savings,
  }) {
    return PlannedPurchase(
      title: title ?? this.title,
      months: months ?? this.months,
      cost: cost ?? this.cost,
      savings: savings ?? this.savings,
    );
  }

  @override
  List<Object?> get props => [title, months, cost, savings];
}