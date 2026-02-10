import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  // Unique User ID
  @HiveField(0)
  final String id;

  // Full Name
  @HiveField(1)
  final String name;

  // Email Address
  @HiveField(2)
  final String email;

  // Password (for local auth demo)
  @HiveField(3)
  final String password;

  // Admin Role
  @HiveField(4)
  final bool isAdmin;

  // Account Created Date
  @HiveField(5)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
    required this.createdAt,
  });

  // CopyWith Method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert Object → Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "isAdmin": isAdmin,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // Convert Map → Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      password: map["password"],
      isAdmin: map["isAdmin"] ?? false,
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}
