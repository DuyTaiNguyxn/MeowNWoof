import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class MedicalRecordService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/medical-records';

  final AuthService _authService;

  MedicalRecordService(this._authService);

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    print('[RecordService] Token retrieved: ${token != null ? "Token exists" : "Token is NULL"}'); 
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<PetMedicalRecord>> getAllMedicalRecords() async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(
          Uri.parse(_baseUrl),
          headers: headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'];
        // print('[RecordService] getAllMedicalRecords responseBody: $responseBody');
        return data.map((json) => PetMedicalRecord.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        // print('[RecordService] getAllMedicalRecords Failed: ${errorBody['message']} Status: ${response.statusCode}');
        throw Exception('Failed to load medical records: ${errorBody['message']}');
      }
    } catch (e) {
      print('Error in getAllMedicalRecords (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<PetMedicalRecord> getMedicalRecordById(int id) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(
          Uri.parse('$_baseUrl/$id'),
          headers: headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return PetMedicalRecord.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Medical record not found');
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to load medical record: ${errorBody['message']}');
      }
    } catch (e) {
      print('Error in getMedicalRecordById: $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<PetMedicalRecord> createMedicalRecord(PetMedicalRecord record) async {
    try {
      final headers = await _getHeadersWithAuth();
      final requestBody = json.encode(record.toJson());

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map<String, dynamic>) {
          return PetMedicalRecord.fromJson(responseBody['data']);
        } else {
          throw Exception('Invalid response format: "data" field missing or not a map.');
        }
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        final String errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to create medical record: $errorMessage (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in createMedicalRecord catch block: $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<PetMedicalRecord> updateMedicalRecord(PetMedicalRecord record) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.put(
        Uri.parse('$_baseUrl/${record.id}'),
        headers: headers,
        body: json.encode(record.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return PetMedicalRecord.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Medical record not found for update');
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to update medical record: ${errorBody['message']}');
      }
    } catch (e) {
      print('Error in updateMedicalRecord: $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<void> deleteMedicalRecord(int id) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.delete(
          Uri.parse('$_baseUrl/$id'),
          headers: headers
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to delete PetMedicalRecord';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error deleting PetMedicalRecord: $e');
      throw Exception('Lỗi khi xóa PetMedicalRecord: $e');
    }
  }

  Future<List<PetMedicalRecord>> getMedicalRecordsByPetId(int petId) async {
    try {
      final headers = await _getHeadersWithAuth();
      final uri = Uri.parse('$_baseUrl/pet/$petId');

      final response = await http.get(
          uri,
          headers: headers
      );

      // print('[RecordService] HTTP Status Code: ${response.statusCode}');
      // print('[RecordService] HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> rawData = responseBody['data'];
        // print('[RecordService] responseBody["data"] received: ${rawData.length} items for petId: $petId');
        final List<PetMedicalRecord> medicalRecords = rawData.map((json) {
          final record = PetMedicalRecord.fromJson(json);
          // print('[RecordService] Parsed Medical Record (fromJson): ${record.toJson()}');
          return record;
        }).toList();

        return medicalRecords;
      } else if (response.statusCode == 404) {
        print('[RecordService] Received 404 for petId: $petId, returning empty list.'); 
        return [];
      }
      else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        print('[RecordService] Non-200/404 status for petId: $petId. Message: ${errorBody['message']} Status: ${response.statusCode}'); 
        throw Exception('Failed to load medical records for pet: ${errorBody['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in getMedicalRecordsByPetId (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }
}