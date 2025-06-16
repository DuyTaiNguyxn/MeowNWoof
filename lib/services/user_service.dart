// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class UserService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  // Sửa đổi ở đây: Nhận AuthService thông qua constructor
  final AuthService _authService;

  // Constructor mới
  UserService(this._authService); // <- Tiêm AuthService vào đây

  // Hàm helper để tạo headers có token
  Future<Map<String, String>> _getHeadersWithAuth() async {
    // Bây giờ _authService là instance được cung cấp bởi Provider
    final String? token = await _authService.getToken();
    if (token == null) {
      // Có thể _currentUser là null, hoặc token đã hết hạn
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
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
        final updatedUser = User.fromJson(responseBodyMap);

        // Sau khi cập nhật thành công, hãy cập nhật trạng thái user trong AuthService
        // để các widget khác cũng nhận được thông tin user mới nhất.
        _authService.updateCurrentUser(updatedUser);

        return updatedUser;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to update user: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user(service): $e');
    }
  }
}