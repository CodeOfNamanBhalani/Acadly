import 'package:uuid/uuid.dart';
import '../data/database/database_service.dart';
import '../data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> init() async {
    // Check if user was previously logged in
    if (_db.isLoggedIn()) {
      _currentUser = _db.getCurrentUser();
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      return AuthResult.failure('Name is required');
    }
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Invalid email format');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters');
    }

    // Check if email already exists
    final existingUser = _db.getUserByEmail(email);
    if (existingUser != null) {
      return AuthResult.failure('Email already registered');
    }

    // Create new user
    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password, // In production, hash this!
      isAdmin: isAdmin,
      createdAt: DateTime.now(),
    );

    await _db.createUser(user);

    // Auto login after signup
    _currentUser = user;
    await _db.setCurrentUserId(user.id);
    await _db.setLoggedIn(true);

    return AuthResult.success(user);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }

    final user = _db.getUserByEmail(email.trim());
    if (user == null) {
      return AuthResult.failure('User not found');
    }

    if (user.password != password) {
      return AuthResult.failure('Incorrect password');
    }

    _currentUser = user;
    await _db.setCurrentUserId(user.id);
    await _db.setLoggedIn(true);

    return AuthResult.success(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _db.setCurrentUserId(null);
    await _db.setLoggedIn(false);
  }

  Future<AuthResult> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure('Not logged in');
    }

    if (name.trim().isEmpty) {
      return AuthResult.failure('Name is required');
    }
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Invalid email format');
    }

    // Check if email is taken by another user
    final existingUser = _db.getUserByEmail(email.trim());
    if (existingUser != null && existingUser.id != _currentUser!.id) {
      return AuthResult.failure('Email already taken');
    }

    final updatedUser = _currentUser!.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );

    await _db.updateUser(updatedUser);
    _currentUser = updatedUser;

    return AuthResult.success(updatedUser);
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure('Not logged in');
    }

    if (_currentUser!.password != currentPassword) {
      return AuthResult.failure('Current password is incorrect');
    }

    if (newPassword.length < 6) {
      return AuthResult.failure('New password must be at least 6 characters');
    }

    final updatedUser = _currentUser!.copyWith(password: newPassword);
    await _db.updateUser(updatedUser);
    _currentUser = updatedUser;

    return AuthResult.success(updatedUser);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;

  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}

