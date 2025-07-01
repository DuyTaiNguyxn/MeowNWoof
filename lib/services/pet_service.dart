// lib/services/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class PetService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String _baseUrl = 'http://192.168.1.XX:3000/api'; // Physical Android/iOS

  final AuthService _authService;

  PetService(this._authService);

  // Hàm helper để tạo headers có token
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

  Future<List<Pet>> getPets() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pets'));

      if (response.statusCode == 200) {
        try {
          final List<dynamic> petJsonList = jsonDecode(response.body);
          List<Pet> pets = petJsonList.map((json) => Pet.fromJson(json)).toList();
          pets.sort((a, b) => (b.petId ?? 0).compareTo(a.petId ?? 0));
          return pets;
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

  Future<Pet> createPet(Pet pet) async {
    try {
      final headers = await _getHeadersWithAuth();

      final petDataJson = jsonEncode(pet.toJson());
      // print('DEBUG: Data being sent to backend for pet creation:');
      // print(petDataJson);

      final response = await http.post(
        Uri.parse('$_baseUrl/pets'),
        headers: headers,
        body: petDataJson,
      );

      // print('DEBUG: createPet Status Code: ${response.statusCode}');
      // print('DEBUG: createPet Response Body: ${response.body}');

      if (response.statusCode == 201) {
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

  Future<Pet> updatePet(Pet pet) async {
    try {
      final headers = await _getHeadersWithAuth();

      Map<String, dynamic> petData = pet.toJson();
      petData.remove('owner');

      final petDataJson = jsonEncode(petData);

      // print('DEBUG: Data being sent for update: $petDataJson');

      final response = await http.put(
        Uri.parse('$_baseUrl/pets/${pet.petId}'),
        headers: headers,
        body: petDataJson,
      );

      // print('DEBUG: updatePet Status Code: ${response.statusCode}');
      // print('DEBUG: updatePet Response Body: ${response.body}');

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

  Future<void> deletePet(int petId) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.delete(
        Uri.parse('$_baseUrl/pets/$petId'),
        headers: headers,
      );

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