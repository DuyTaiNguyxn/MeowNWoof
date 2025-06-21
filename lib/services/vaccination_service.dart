import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/vaccination.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class VaccinationService {
  final String _baseUrl = 'http://10.0.2.2:3000/api/vaccinations';

  final AuthService _authService;

  VaccinationService(this._authService);

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    print('[VaccinationService] Token: ${token != null ? "exists" : "NULL"}');
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Vaccination>> getAllVaccinations() async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => Vaccination.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception('Lỗi lấy danh sách: ${error['message']} (Status ${response.statusCode})');
      }
    } catch (e) {
      print('Error in getAllVaccinations: $e');
      throw Exception('Lỗi kết nối server hoặc xử lý dữ liệu: $e');
    }
  }

  Future<Vaccination> getVaccinationById(int id) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(Uri.parse('$_baseUrl/$id'), headers: headers);

      print('[VaccinationService] getVaccinationById Status: ${response.statusCode}');
      print('[VaccinationService] getVaccinationById Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return Vaccination.fromJson(body['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy lịch tiêm với ID: $id');
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception('Lỗi lấy lịch tiêm: ${error['message']}');
      }
    } catch (e) {
      print('Error in getVaccinationById: $e');
      throw Exception('Lỗi kết nối server hoặc xử lý dữ liệu: $e');
    }
  }

  Future<Vaccination> createVaccination(Vaccination vaccination) async {
    try {
      final headers = await _getHeadersWithAuth();
      final body = json.encode(vaccination.toJson());

      final response = await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Vaccination.fromJson(responseBody['data']);
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception('Tạo mới thất bại: ${error['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in createVaccination: $e');
      throw Exception('Lỗi kết nối server hoặc xử lý dữ liệu: $e');
    }
  }

  Future<Vaccination> updateVaccination(int id, Vaccination vaccination) async {
    try {
      final headers = await _getHeadersWithAuth();
      final body = json.encode(vaccination.toJson());

      final response = await http.put(Uri.parse('$_baseUrl/$id'), headers: headers, body: body);

      print('[VaccinationService] updateVaccination Status: ${response.statusCode}');
      print('[VaccinationService] updateVaccination Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Vaccination.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy lịch tiêm để cập nhật: ID $id');
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception('Cập nhật thất bại: ${error['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in updateVaccination: $e');
      throw Exception('Lỗi kết nối server hoặc xử lý dữ liệu: $e');
    }
  }

  Future<Vaccination> updateVaccinationStatus(int id, String newStatus) async {
    try {
      final headers = await _getHeadersWithAuth();
      final body = json.encode({'status': newStatus});

      final response = await http.put(
        Uri.parse('$_baseUrl/status/$id'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Vaccination.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy lịch tiêm để cập nhật trạng thái: ID $id');
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception('Lỗi cập nhật trạng thái: ${error['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in updateVaccinationStatus: $e');
      throw Exception('Lỗi kết nối server hoặc xử lý dữ liệu: $e');
    }
  }
}
