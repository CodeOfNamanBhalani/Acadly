import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://student-planner-api-fa7e.onrender.com';

  // Token keys for SharedPreferences
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  // Initialize - load tokens from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  // Check if user has valid tokens
  bool get hasTokens => _accessToken != null && _accessToken!.isNotEmpty;

  // Save tokens to storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Clear tokens from storage
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Get headers with authorization
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Refresh token if needed
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
        return true;
      }
    } catch (e) {
      // Refresh failed
    }
    return false;
  }

  // Generic API request with auto-refresh on 401
  Future<ApiResponse> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      final headers = _getHeaders(includeAuth: requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;

      // Add timeout to prevent infinite loading
      final client = http.Client();
      try {
        switch (method) {
          case 'GET':
            response = await client.get(uri, headers: headers).timeout(const Duration(seconds: 30));
            break;
          case 'POST':
            response = await client.post(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 30));
            break;
          case 'PUT':
            response = await client.put(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 30));
            break;
          case 'PATCH':
            response = await client.patch(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 30));
            break;
          case 'DELETE':
            response = await client.delete(uri, headers: headers).timeout(const Duration(seconds: 30));
            break;
          default:
            return ApiResponse.failure('Invalid HTTP method');
        }
      } finally {
        client.close();
      }

      // Handle 401 - try refresh token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return _request(method, endpoint, body: body, requiresAuth: requiresAuth);
        } else {
          await clearTokens();
          return ApiResponse.failure('Session expired. Please login again.', statusCode: 401);
        }
      }

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.failure('No internet connection');
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    print('API Response - Status: ${response.statusCode}, Body: ${response.body}');
    try {
      final data = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(data);
      } else {
        final message = data is Map ? (data['detail'] ?? data['message'] ?? 'Unknown error') : 'Request failed';
        return ApiResponse.failure(message.toString(), statusCode: response.statusCode);
      }
    } catch (e) {
      print('Parse error: $e');
      return ApiResponse.failure('Failed to parse response');
    }
  }

  // ==================== AUTHENTICATION ====================

  Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final accessToken = data['access_token'] ?? data['token'] ?? data['accessToken'];
      final refreshToken = data['refresh_token'] ?? data['refreshToken'] ?? accessToken;

      if (accessToken != null) {
        await _saveTokens(accessToken, refreshToken ?? accessToken);
      }
    }

    return response;
  }

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/login',
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    // Debug: Print login response
    print('Login API response: ${response.data}');

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      final accessToken = data['access_token'] ?? data['token'] ?? data['accessToken'];
      final refreshToken = data['refresh_token'] ?? data['refreshToken'] ?? accessToken;

      if (accessToken != null) {
        await _saveTokens(accessToken, refreshToken ?? accessToken);
      }
    }

    return response;
  }

  Future<ApiResponse> getProfile() async {
    final response = await _request('GET', '/me');
    print('Profile API response: ${response.data}');
    return response;
  }

  Future<void> logout() async {
    await clearTokens();
  }

  // ==================== TIMETABLE ====================

  Future<ApiResponse> getTimetable() async {
    final response = await _request('GET', '/timetable');
    print('GET /timetable response: ${response.data}');
    return response;
  }

  Future<ApiResponse> createTimetableEntry({
    required String subject,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
    required String teacher,
  }) async {
    // API expects day as string like "Monday", "Tuesday", etc.
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[dayOfWeek];

    final response = await _request('POST', '/timetable', body: {
      'subject': subject,
      'day': dayName,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'teacher': teacher,
    });
    print('POST /timetable response: success=${response.isSuccess}, data=${response.data}, error=${response.errorMessage}');
    return response;
  }

  Future<ApiResponse> updateTimetableEntry({
    required String id,
    required String subject,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
    required String teacher,
  }) async {
    // API expects day as string like "Monday", "Tuesday", etc.
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[dayOfWeek];

    return _request('PUT', '/timetable/$id', body: {
      'subject': subject,
      'day': dayName,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'teacher': teacher,
    });
  }

  Future<ApiResponse> deleteTimetableEntry(String id) async {
    return _request('DELETE', '/timetable/$id');
  }

  // ==================== ASSIGNMENTS ====================

  Future<ApiResponse> getAssignments() async {
    final response = await _request('GET', '/assignments');
    print('GET /assignments response: ${response.data}');
    return response;
  }

  Future<ApiResponse> createAssignment({
    required String title,
    required String subject,
    String? description,
    required String dueDate,
    required String status,
    required String priority,
  }) async {
    final response = await _request('POST', '/assignments', body: {
      'title': title,
      'subject': subject,
      'description': description ?? '',
      'due_date': dueDate,
      'status': status,
      'priority': priority,
    });
    print('POST /assignments response: success=${response.isSuccess}, data=${response.data}, error=${response.errorMessage}');
    return response;
  }

  Future<ApiResponse> updateAssignment({
    required String id,
    required String title,
    required String subject,
    String? description,
    required String dueDate,
    required String status,
    required String priority,
  }) async {
    return _request('PUT', '/assignments/$id', body: {
      'title': title,
      'subject': subject,
      'description': description ?? '',
      'due_date': dueDate,
      'status': status,
      'priority': priority,
    });
  }

  Future<ApiResponse> deleteAssignment(String id) async {
    return _request('DELETE', '/assignments/$id');
  }

  Future<ApiResponse> completeAssignment(String id) async {
    return _request('PATCH', '/assignments/$id/complete');
  }

  Future<ApiResponse> getUpcomingAssignments() async {
    return _request('GET', '/assignments/upcoming');
  }

  Future<ApiResponse> getOverdueAssignments() async {
    return _request('GET', '/assignments/overdue');
  }

  // ==================== EXAMS ====================

  Future<ApiResponse> getExams() async {
    final response = await _request('GET', '/exams');
    print('GET /exams response: ${response.data}');
    return response;
  }

  Future<ApiResponse> createExam({
    required String subject,
    required String examType,
    required String examDate,
    required String room,
    String? notes,
  }) async {
    final response = await _request('POST', '/exams', body: {
      'subject': subject,
      'exam_type': examType,
      'exam_date': examDate,
      'room': room,
      'notes': notes ?? '',
    });
    print('POST /exams response: success=${response.isSuccess}, data=${response.data}, error=${response.errorMessage}');
    return response;
  }

  Future<ApiResponse> updateExam({
    required String id,
    required String subject,
    required String examType,
    required String examDate,
    required String room,
    String? notes,
  }) async {
    return _request('PUT', '/exams/$id', body: {
      'subject': subject,
      'exam_type': examType,
      'exam_date': examDate,
      'room': room,
      'notes': notes ?? '',
    });
  }

  Future<ApiResponse> deleteExam(String id) async {
    return _request('DELETE', '/exams/$id');
  }

  Future<ApiResponse> getUpcomingExams() async {
    return _request('GET', '/exams/upcoming');
  }

  // ==================== NOTES ====================

  Future<ApiResponse> getNotes() async {
    final response = await _request('GET', '/notes');
    print('GET /notes response: ${response.data}');
    return response;
  }

  Future<ApiResponse> createNote({
    required String title,
    required String content,
  }) async {
    final response = await _request('POST', '/notes', body: {
      'title': title,
      'content': content,
    });
    print('POST /notes response: success=${response.isSuccess}, data=${response.data}, error=${response.errorMessage}');
    return response;
  }

  Future<ApiResponse> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    return _request('PUT', '/notes/$id', body: {
      'title': title,
      'content': content,
    });
  }

  Future<ApiResponse> deleteNote(String id) async {
    return _request('DELETE', '/notes/$id');
  }
}

// API Response wrapper
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(isSuccess: true, data: data);
  }

  factory ApiResponse.failure(String message, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

