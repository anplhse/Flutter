import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/visitor.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  Visitor? _currentVisitor;

  String? get token => _token;
  Visitor? get currentVisitor => _currentVisitor;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // Load token từ shared preferences khi app khởi động
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.keyAuthToken);

    if (_token != null) {
      final userId = prefs.getString(AppConstants.keyUserId);
      final username = prefs.getString(AppConstants.keyUsername);
      final status = prefs.getString(AppConstants.keyUserStatus);
      final createdAt = prefs.getString('user_created_at');
      final updatedAt = prefs.getString('user_updated_at');

      if (userId != null && username != null && status != null &&
          createdAt != null && updatedAt != null) {
        _currentVisitor = Visitor(
          id: userId,
          username: username,
          status: status,
          createdAt: DateTime.parse(createdAt),
          updatedAt: DateTime.parse(updatedAt),
        );
      }
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['code'] == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy thông tin profile từ API
  Future<bool> fetchProfile() async {
    try {
      if (_token == null || _token!.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visitors/me'),
        headers: getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final visitorData = data['data'];
          _currentVisitor = Visitor.fromJson(visitorData);

          // Lưu thông tin visitor vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.keyUserId, _currentVisitor!.id);
          await prefs.setString(AppConstants.keyUsername, _currentVisitor!.username);
          await prefs.setString(AppConstants.keyUserStatus, _currentVisitor!.status);
          await prefs.setString('user_created_at', _currentVisitor!.createdAt.toIso8601String());
          await prefs.setString('user_updated_at', _currentVisitor!.updatedAt.toIso8601String());

          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return false;
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['code'] == 200) {
        _token = data['data']['token'];

        // Lưu token vào shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyAuthToken, _token!);

        // Lấy thông tin profile từ API /visitors/me
        final profileSuccess = await fetchProfile();

        if (!profileSuccess) {
          // Nếu không lấy được profile, vẫn lưu username tạm thời
          await prefs.setString(AppConstants.keyUsername, username);
        }

        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    _token = null;
    _currentVisitor = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUsername);
    await prefs.remove(AppConstants.keyUserStatus);
    await prefs.remove('user_created_at');
    await prefs.remove('user_updated_at');
  }

  // Lấy headers với token
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}

