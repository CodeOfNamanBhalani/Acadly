class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to API JSON format
  Map<String, dynamic> toJson() {
    return {
      'username': name,
      'email': email,
    };
  }

  // Create from API JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Legacy methods for compatibility
  Map<String, dynamic> toMap() => toJson();
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);
}
