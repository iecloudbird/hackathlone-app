/// Mentor model for displaying mentor information
class Mentor {
  final String id;
  final String name;
  final String role;
  final String company;
  final String description;
  final String? imageUrl;
  final bool isActive;

  const Mentor({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.description,
    this.imageUrl,
    this.isActive = true,
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
  };

  /// Get formatted role with company
  String get formattedRole => '$role at $company';
}
