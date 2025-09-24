/// Enum for mentor availability type
enum MentorType {
  onground('Onsite'),
  online('Online');

  const MentorType(this.displayName);
  final String displayName;

  static MentorType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return MentorType.online;
      case 'onground':
      default:
        return MentorType.onground;
    }
  }
}

/// Mentor model for displaying mentor information
class Mentor {
  final String id;
  final String name;
  final String role;
  final String company;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final String? linkedinUrl;
  final String? activeHours;
  final MentorType mentorType;
  final List<String> specializations;

  const Mentor({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.description,
    this.imageUrl,
    this.isActive = true,
    this.linkedinUrl,
    this.activeHours,
    this.mentorType = MentorType.onground,
    this.specializations = const [],
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      company: json['company'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      linkedinUrl: json['linkedin_url'] as String?,
      activeHours: json['active_hours'] as String?,
      mentorType: MentorType.fromString(
        json['mentor_type'] as String? ?? 'onground',
      ),
      specializations: _parseSpecializations(json['specializations']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'company': company,
    'description': description,
    'image_url': imageUrl,
    'is_active': isActive,
    'linkedin_url': linkedinUrl,
    'active_hours': activeHours,
    'mentor_type': mentorType.name,
    'specializations': specializations,
  };

  /// Parse specializations from JSON (can be array or comma-separated string)
  static List<String> _parseSpecializations(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Get formatted role with company
  String get formattedRole => '$role at $company';

  /// Get formatted active hours for display
  String get formattedActiveHours {
    if (activeHours == null || activeHours!.isEmpty) {
      return mentorType == MentorType.online
          ? 'Available Online'
          : 'Available Onsite';
    }
    return activeHours!;
  }

  /// Check if mentor has LinkedIn URL
  bool get hasLinkedIn => linkedinUrl != null && linkedinUrl!.isNotEmpty;

  /// Get mentor type color for UI
  String get mentorTypeColor {
    switch (mentorType) {
      case MentorType.online:
        return '#4CAF50'; // Green
      case MentorType.onground:
        return '#FF9800'; // Orange
    }
  }

  /// Get top specializations (max 3 for display)
  List<String> get topSpecializations => specializations.take(3).toList();
}
