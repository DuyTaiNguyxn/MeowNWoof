// meow_n_woof/lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // Import để sử dụng ChangeNotifier
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:meow_n_woof/models/user.dart'; // Import model User

// Thay đổi AuthService để kế thừa ChangeNotifier
class AuthService extends ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // IP máy ảo

  User? _currentUser; // Biến private để lưu trữ User hiện tại của ứng dụng

  // Getter công khai để các widget có thể truy cập User hiện tại
  User? get currentUser => _currentUser;

  // Constructor của AuthService: Tải user từ SharedPreferences khi AuthService được khởi tạo
  AuthService() {
    _loadUserFromPrefs();
  }

  // Phương thức nội bộ để tải User từ SharedPreferences
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners(); // Thông báo cho người nghe nếu user được tải thành công
      } catch (e) {
        print('Lỗi khi parse user từ SharedPreferences: $e');
        _currentUser = null; // Đặt null nếu có lỗi parse
      }
    }
  }

  // Phương thức nội bộ để lưu User vào SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Phương thức nội bộ để xóa User khỏi SharedPreferences
  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Hàm đăng nhập (login)
  Future<Map<String, dynamic>> login(String username, String password) async {
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
          _currentUser = User.fromJson(responseData['user']); // Cập nhật _currentUser
          await _saveUserToPrefs(_currentUser!); // Lưu user vào SharedPreferences
          notifyListeners(); // Thông báo cho tất cả người nghe
        }
      }
      return responseData;
    } on TimeoutException catch (_) {
      throw Exception('Kết nối máy chủ quá lâu hoặc không phản hồi. Vui lòng thử lại.');
    } on Exception catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  // Hàm lấy token đã lưu (giữ nguyên)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Hàm xóa token và user (đăng xuất)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    await prefs.remove('remember_me');
    await prefs.remove('saved_username');
    _currentUser = null; // Xóa user hiện tại
    notifyListeners(); // Thông báo cho tất cả người nghe rằng user đã bị xóa
  }

  // Hàm NỘI BỘ để lưu token vào SharedPreferences (giữ nguyên)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Hàm xử lý phản hồi HTTP chung (giữ nguyên)
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đã xảy ra lỗi!');
    }
  }

  // PHƯƠNG THỨC MỚI: Cập nhật thông tin User hiện tại và thông báo
  void updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserToPrefs(_currentUser!); // Lưu thông tin cập nhật vào prefs
    notifyListeners(); // Thông báo cho tất cả các widget đang lắng nghe
  }
}