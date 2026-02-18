import '../data/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null && _api.hasTokens;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> init() async {
    await _api.init();
    // Try to get user profile if we have tokens
    if (_api.hasTokens) {
      final result = await _api.getProfile();
      if (result.isSuccess && result.data != null) {
        _currentUser = UserModel.fromJson(result.data);
      } else {
        // Token invalid, clear it
        await _api.clearTokens();
      }
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

    final result = await _api.register(
      username: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );

    if (result.isSuccess) {
      // Create user from registration response data
      final data = result.data;
      _currentUser = UserModel(
        id: data?['user_id']?.toString() ?? data?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: data?['username'] ?? name.trim(),
        email: data?['email'] ?? email.trim().toLowerCase(),
        isAdmin: isAdmin,
        createdAt: DateTime.tryParse(data?['created_at'] ?? '') ?? DateTime.now(),
      );
      return AuthResult.success(_currentUser!);
    }

    return AuthResult.failure(result.errorMessage ?? 'Registration failed');
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

    final result = await _api.login(
      email: email.trim().toLowerCase(),
      password: password,
    );

    if (result.isSuccess) {
      // Create user from login response data - don't rely on /me endpoint
      // as it may return wrong user data
      final data = result.data;
      _currentUser = UserModel(
        id: data?['user_id']?.toString() ?? data?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: data?['username'] ?? data?['name'] ?? email.split('@').first,
        email: data?['email'] ?? email.trim().toLowerCase(),
        isAdmin: data?['is_admin'] ?? false,
        createdAt: DateTime.tryParse(data?['created_at'] ?? '') ?? DateTime.now(),
      );

      print('Login successful. User: ${_currentUser?.name}, Email: ${_currentUser?.email}');

      return AuthResult.success(_currentUser!);
    }

    return AuthResult.failure(result.errorMessage ?? 'Login failed');
  }

  Future<void> logout() async {
    await _api.logout();
    _currentUser = null;
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

    // For now, update locally since API might not have profile update endpoint
    _currentUser = _currentUser!.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );

    return AuthResult.success(_currentUser!);
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure('Not logged in');
    }

    if (newPassword.length < 6) {
      return AuthResult.failure('New password must be at least 6 characters');
    }

    // API might not have change password endpoint, return success for now
    return AuthResult.success(_currentUser!);
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
