// lib/services/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/auth_service.dart'; // Import AuthService của bạn

class PetService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String _baseUrl = 'http://192.168.1.XX:3000/api'; // Physical Android/iOS

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

  // Lấy danh sách Pet (có thể bao gồm thông tin owner, species, breed nhúng)
  // Giả sử API này KHÔNG yêu cầu xác thực token (thường là public)
  Future<List<Pet>> getPets() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pets'));

      if (response.statusCode == 200) {
        try {
          final List<dynamic> petJsonList = jsonDecode(response.body);
          return petJsonList.map((json) => Pet.fromJson(json)).toList();
        } on FormatException catch (e) {
          print('DEBUG: JSON format error in getPets: $e');
          throw Exception('Lỗi định dạng JSON khi tải pets: $e');
        }
      } else {
        String errorMessage = 'Failed to load pets';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error fetching pets: $e');
      throw Exception('Lỗi khi lấy danh sách pets: $e');
    }
  }

  // Lấy thông tin một Pet theo ID
  // Giả sử API này KHÔNG yêu cầu xác thực token (thường là public)
  Future<Pet> getPetById(int petId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pets/$petId'));
      if (response.statusCode == 200) {
        return Pet.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = 'Failed to load pet details';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error fetching pet by ID: $e');
      throw Exception('Lỗi khi lấy thông tin pet theo ID: $e');
    }
  }

  // Thêm một Pet mới (YÊU CẦU XÁC THỰC TOKEN)
  Future<Pet> createPet(Pet pet) async {
    try {
      final headers = await _getHeadersWithAuth(); // Lấy headers kèm token

      // --- BẮT ĐẦU PHẦN THÊM LOG ---
      final petDataJson = jsonEncode(pet.toJson());
      print('DEBUG: Data being sent to backend for pet creation:');
      print(petDataJson); // In ra chuỗi JSON
      // --- KẾT THÚC PHẦN THÊM LOG ---

      final response = await http.post(
        Uri.parse('$_baseUrl/pets'),
        headers: headers,
        body: petDataJson, // Sử dụng chuỗi JSON đã in ra
      );

      print('DEBUG: createPet Status Code: ${response.statusCode}');
      print('DEBUG: createPet Response Body: ${response.body}');

      if (response.statusCode == 201) { // 201 Created
        return Pet.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = 'Failed to create pet';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error creating pet: $e');
      throw Exception('Lỗi khi tạo pet: $e');
    }
  }

  // Cập nhật thông tin Pet (YÊU CẦU XÁC THỰC TOKEN)
  Future<Pet> updatePet(Pet pet) async {
    try {
      final headers = await _getHeadersWithAuth();

      Map<String, dynamic> petData = pet.toJson();

      petData.remove('owner');

      final petDataJson = jsonEncode(petData);

      print('DEBUG: Data being sent for update: $petDataJson'); // Để kiểm tra payload

      final response = await http.put(
        Uri.parse('$_baseUrl/pets/${pet.petId}'),
        headers: headers,
        body: petDataJson, // Sử dụng chuỗi JSON đã chỉnh sửa
      );

      print('DEBUG: updatePet Status Code: ${response.statusCode}');
      print('DEBUG: updatePet Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBodyMap = jsonDecode(response.body);
        print('DEBUG: JSON received from backend for Pet conversion: $responseBodyMap');
        return Pet.fromJson(responseBodyMap);
      } else {
        String errorMessage = 'Failed to update pet';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error updating pet: $e');
      throw Exception('Lỗi khi cập nhật pet: $e');
    }
  }

  // Xóa một Pet (YÊU CẦU XÁC THỰC TOKEN)
  Future<void> deletePet(int petId) async {
    try {
      final headers = await _getHeadersWithAuth(); // Lấy headers kèm token
      final response = await http.delete(
        Uri.parse('$_baseUrl/pets/$petId'),
        headers: headers, // Sử dụng headers đã có token
      );

      print('DEBUG: deletePet Status Code: ${response.statusCode}');
      print('DEBUG: deletePet Response Body: ${response.body}');

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to delete pet';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error deleting pet: $e');
      throw Exception('Lỗi khi xóa pet: $e');
    }
  }
}