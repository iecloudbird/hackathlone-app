/// Enum for meal times during the day
enum MealTime {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner');

  const MealTime(this.displayName);
  final String displayName;

  static MealTime fromString(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealTime.breakfast;
      case 'lunch':
        return MealTime.lunch;
      case 'dinner':
        return MealTime.dinner;
      default:
        return MealTime.lunch;
    }
  }
}

/// Enum for hackathon days
enum HackathonDay {
  friday('Oct 3'),
  saturday('Oct 4'),
  sunday('Oct 5');

  const HackathonDay(this.displayName);
  final String displayName;

  static HackathonDay fromString(String value) {
    switch (value.toLowerCase()) {
      case 'friday':
        return HackathonDay.friday;
      case 'saturday':
        return HackathonDay.saturday;
      case 'sunday':
        return HackathonDay.sunday;
      default:
        return HackathonDay.friday;
    }
  }
}

/// Meal model for displaying meal information during hackathon
class Meal {
  final String id;
  final HackathonDay day;
  final MealTime mealTime;
  final String? provider;
  final String? description;
  final List<String> mains;
  final List<String> sides;
  final List<String> dietaryOptions;
  final List<String> items; // For buffet-style meals like breakfast
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Meal({
    required this.id,
    required this.day,
    required this.mealTime,
    this.provider,
    this.description,
    this.mains = const [],
    this.sides = const [],
    this.dietaryOptions = const [],
    this.items = const [],
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      day: HackathonDay.fromString(json['day'] as String),
      mealTime: MealTime.fromString(json['meal_time'] as String),
      provider: json['provider'] as String?,
      description: json['description'] as String?,
      mains: _parseStringArray(json['mains']),
      sides: _parseStringArray(json['sides']),
      dietaryOptions: _parseStringArray(json['dietary_options']),
      items: _parseStringArray(json['items']),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'day': day.name,
    'meal_time': mealTime.name,
    'provider': provider,
    'description': description,
    'mains': mains,
    'sides': sides,
    'dietary_options': dietaryOptions,
    'items': items,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Parse string array from JSON (handles both List of String and PostgreSQL array format)
  static List<String> _parseStringArray(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (value is String) {
      // Handle PostgreSQL array format like: {item1,item2,item3}
      if (value.startsWith('{') && value.endsWith('}')) {
        final content = value.substring(1, value.length - 1);
        if (content.isEmpty) return [];
        return content
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      // Handle comma-separated format
      return value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Get formatted meal title for display
  String get formattedTitle => '${day.displayName} ${mealTime.displayName}';

  /// Get formatted provider info
  String get formattedProvider => provider ?? 'TBA';

  /// Check if meal has main dishes
  bool get hasMainDishes => mains.isNotEmpty;

  /// Check if meal has sides
  bool get hasSides => sides.isNotEmpty;

  /// Check if meal has buffet items
  bool get hasItems => items.isNotEmpty;

  /// Check if meal has dietary options
  bool get hasDietaryOptions => dietaryOptions.isNotEmpty;

  /// Check if meal has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Get meal time color for UI
  String get mealTimeColor {
    switch (mealTime) {
      case MealTime.breakfast:
        return '#FF9800'; // Orange
      case MealTime.lunch:
        return '#2196F3'; // Blue
      case MealTime.dinner:
        return '#9C27B0'; // Purple
    }
  }

  /// Get day color for UI
  String get dayColor {
    switch (day) {
      case HackathonDay.friday:
        return '#F44336'; // Red
      case HackathonDay.saturday:
        return '#4CAF50'; // Green
      case HackathonDay.sunday:
        return '#FF5722'; // Deep Orange
    }
  }

  /// Check if this is a breakfast meal
  bool get isBreakfast => mealTime == MealTime.breakfast;

  /// Check if this is a lunch meal
  bool get isLunch => mealTime == MealTime.lunch;

  /// Check if this is a dinner meal
  bool get isDinner => mealTime == MealTime.dinner;

  /// Get all food content as a combined list for search
  List<String> get allFoodItems => [...mains, ...sides, ...items];

  /// Copy method for creating modified instances
  Meal copyWith({
    String? id,
    HackathonDay? day,
    MealTime? mealTime,
    String? provider,
    String? description,
    List<String>? mains,
    List<String>? sides,
    List<String>? dietaryOptions,
    List<String>? items,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      day: day ?? this.day,
      mealTime: mealTime ?? this.mealTime,
      provider: provider ?? this.provider,
      description: description ?? this.description,
      mains: mains ?? this.mains,
      sides: sides ?? this.sides,
      dietaryOptions: dietaryOptions ?? this.dietaryOptions,
      items: items ?? this.items,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
