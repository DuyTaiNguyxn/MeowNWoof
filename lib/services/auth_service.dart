// meow_n_woof/lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:meow_n_woof/models/user.dart';

class AuthService extends ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // IP máy ảo

  User? _currentUser;

  User? get currentUser => _currentUser;

  AuthService() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        // print('AuthService: Đã tải user từ SharedPreferences: ${_currentUser?.username ?? 'N/A'}');
        // print('AuthService: Ngày sinh từ SharedPreferences: ${_currentUser?.birth}');
        notifyListeners();
        // print('AuthService: notifyListeners() called after loading user from prefs.');
      } catch (e) {
        print('AuthService: Lỗi khi parse user từ SharedPreferences: $e');
        _currentUser = null;
      }
    } else {
      print('AuthService: Không có user_data trong SharedPreferences.');
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    print('AuthService: Đã lưu user vào SharedPreferences. Birth: ${user.birth.toIso8601String()}');
  }

  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<Map<String, dynamic>> login(String username, String password, bool rememberMe) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final responseData = _handleResponse(response);

      if (response.statusCode == 200 && responseData.containsKey('token')) {
        await _saveToken(responseData['token']);

        if (responseData.containsKey('user')) {
          _currentUser = User.fromJson(responseData['user']);

          if (rememberMe) {
            await _saveUserToPrefs(_currentUser!);
          } else {
            await _removeUserFromPrefs();
          }
          notifyListeners();
        }
      }
      return responseData;
    } on TimeoutException catch (_) {
      throw Exception('Kết nối máy chủ quá lâu hoặc không phản hồi. Vui lòng thử lại.');
    } on Exception catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    await prefs.remove('remember_me');
    await prefs.remove('saved_username');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đã xảy ra lỗi!');
    }
  }

  void updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserToPrefs(_currentUser!);
    notifyListeners();
  }
}