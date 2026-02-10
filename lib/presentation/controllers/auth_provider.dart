import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isAdmin => _authService.isAdmin;

  UserModel? get currentUser => _authService.currentUser;

  // Init Auth (Load session)
  Future<void> init() async {
    await _authService.init();
    notifyListeners();
  }

  // ----------------------------
  // SIGNUP
  // ----------------------------
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    _setLoading(true);

    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      isAdmin: isAdmin,
    );

    _handleResult(result);
    return result.isSuccess;
  }

  // ----------------------------
  // LOGIN
  // ----------------------------
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _handleResult(result);
    return result.isSuccess;
  }

  // ----------------------------
  // LOGOUT
  // ----------------------------
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  // ----------------------------
  // UPDATE PROFILE
  // ----------------------------
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    _setLoading(true);

    final result = await _authService.updateProfile(
      name: name,
      email: email,
    );

    _handleResult(result);
    return result.isSuccess;
  }

  // ----------------------------
  // CHANGE PASSWORD
  // ----------------------------
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _handleResult(result);
    return result.isSuccess;
  }

  // ----------------------------
  // ERROR HANDLING
  // ----------------------------
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ----------------------------
  // PRIVATE HELPERS
  // ----------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _handleResult(AuthResult result) {
    _isLoading = false;

    if (!result.isSuccess) {
      _error = result.errorMessage;
    }

    notifyListeners();
  }
}
