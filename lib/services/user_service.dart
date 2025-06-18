// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class UserService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  final AuthService _authService;

  UserService(this._authService);

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

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

  Future<List<User>> _fetchUsers() async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load users: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all users(service): $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    return _fetchUsers();
  }

  Future<List<User>> getStaffUsers() async {
    final List<User> allUsers = await _fetchUsers();
    return allUsers.where((user) => user.role == 'staff').toList();
  }

  Future<List<User>> getVeterinarianUsers() async {
    final List<User> allUsers = await _fetchUsers();
    return allUsers.where((user) => user.role == 'veterinarian').toList();
  }
}