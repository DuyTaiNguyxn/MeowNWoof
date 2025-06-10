import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:meow_n_woof/models/user.dart'; // Import model User

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // IP máy ảo

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
        // LƯU THÔNG TIN USER VÀO SHARED_PREFERENCES
        if (responseData.containsKey('user')) {
          // Khi backend trả về user (dạng Map), ta lưu nó.
          // Sau này khi đọc ra, ta sẽ convert nó thành User object.
          await _saveUser(responseData['user']);
        }
      }
      return responseData;
    } on TimeoutException catch (_) {
      throw Exception('Kết nối máy chủ quá lâu hoặc không phản hồi. Vui lòng thử lại.');
    } on Exception catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  // Hàm lấy token đã lưu
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Hàm lấy thông tin user đã lưu
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      final Map<String, dynamic> jsonData = jsonDecode(userJson);
      return User.fromJson(jsonData); // Chuyển đổi JSON thành đối tượng User
    }
    return null;
  }

  // Hàm xóa token (đăng xuất)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    await prefs.remove('remember_me');
    await prefs.remove('saved_username');
  }

  // Hàm NỘI BỘ để lưu token vào SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Hàm NỘI BỘ để lưu user data vào SharedPreferences
  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Hàm xử lý phản hồi HTTP chung
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đã xảy ra lỗi!');
    }
  }

}