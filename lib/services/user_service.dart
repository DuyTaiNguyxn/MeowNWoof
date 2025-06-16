// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class UserService {
  // Thay thế bằng URL API backend của bạn
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  final AuthService _authService = AuthService(); // Khởi tạo AuthService để lấy token

  // Hàm helper để tạo headers có token
  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Thêm token vào header
    };
  }

  // Phương thức để cập nhật thông tin người dùng
  Future<User> updateUser(User user) async {
    try {
      final headers = await _getHeadersWithAuth();
      Map<String, dynamic> userData = user.toJson();

      final userDataJson = jsonEncode(userData);
      print('DEBUG: Data being sent for update: $userDataJson');

      final response = await http.put(
        Uri.parse('$_baseUrl/users/${user.employeeId}'),
        headers: headers,
        body: userDataJson,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBodyMap = jsonDecode(response.body);
        print('DEBUG: Json tra ve: $responseBodyMap');
        return User.fromJson(responseBodyMap);
      } else {
        // Xử lý lỗi từ server
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to update user: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      // Xử lý các lỗi mạng hoặc lỗi khác
      throw Exception('Error updating user(service): $e');
    }
  }

}