/// Meal allowance model for tracking user meal voucher allowances
class MealAllowance {
  final String id;
  final String userId;
  final String mealType;
  final int remainingCount;
  final int totalAllowed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MealAllowance({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.remainingCount,
    required this.totalAllowed,
    required this.createdAt,
    this.updatedAt,
  });

  factory MealAllowance.fromJson(Map<String, dynamic> json) {
    return MealAllowance(
      id: json['id'],
      userId: json['user_id'],
      mealType: json['meal_type'],
      remainingCount: json['remaining_count'],
      totalAllowed: json['total_allowed'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_type': mealType,
      'remaining_count': remainingCount,
      'total_allowed': totalAllowed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if user has remaining allowances for this meal type
  bool get hasRemaining => remainingCount > 0;

  /// Get the used count
  int get usedCount => totalAllowed - remainingCount;
}
