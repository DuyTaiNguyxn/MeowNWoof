import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/prescription.dart';
import 'package:meow_n_woof/models/prescription_item.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class PrescriptionService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  final AuthService _authService;

  PrescriptionService(this._authService);

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không có token. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Prescription>> getAllPrescriptions() async {
    final headers = await _getHeadersWithAuth();
    final response = await http.get(
      Uri.parse('$_baseUrl/prescriptions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Prescription.fromJson(e)).toList();
    } else {
      throw Exception('Không thể load danh sách đơn thuốc');
    }
  }

  Future<Prescription> getPrescriptionByRecordId(int id) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.get(
      Uri.parse('$_baseUrl/prescriptions/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print('📦 JSON từ server: $data');
      return Prescription.fromJson(data);
    } else {
      throw Exception('Không thể lấy đơn thuốc');
    }
  }

  Future<Prescription> createPrescription(Prescription prescription) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.post(
      Uri.parse('$_baseUrl/prescriptions'),
      headers: headers,
      body: json.encode(prescription.toJson()),
    );

    if (response.statusCode == 201) {
      return Prescription.fromJson(json.decode(response.body));
    } else {
      throw Exception('Tạo đơn thuốc thất bại');
    }
  }

  Future<Prescription> updatePrescription(Prescription prescription) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.put(
      Uri.parse('$_baseUrl/prescriptions/${prescription.prescriptionId}'),
      headers: headers,
      body: json.encode(prescription.toJson()),
    );

    print('[Update Prescription] Status: ${response.statusCode}');
    print('[Update Prescription] Body: ${response.body}');

    if (response.statusCode == 200) {
      return Prescription.fromJson(json.decode(response.body));
    } else {
      throw Exception('Cập nhật đơn thuốc thất bại');
    }
  }

  Future<PrescriptionItem> addPrescriptionItem(PrescriptionItem item) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.post(
      Uri.parse('$_baseUrl/prescription-items'),
      headers: headers,
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return PrescriptionItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Thêm chi tiết thất bại');
    }
  }

  Future<PrescriptionItem> updatePrescriptionItem(PrescriptionItem item) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.put(
      Uri.parse('$_baseUrl/prescription-items/${item.itemId}'),
      headers: headers,
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return PrescriptionItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Cập nhật chi tiết thất bại');
    }
  }

  Future<void> removePrescriptionItem(int itemId) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.delete(
      Uri.parse('$_baseUrl/prescription-items/$itemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Xoá chi tiết thất bại');
    }
  }

  Future<List<PrescriptionItem>> getItemsByPrescriptionId(int prescriptionId) async {
    final headers = await _getHeadersWithAuth();
    final response = await http.get(
      Uri.parse('$_baseUrl/prescription-items/prescription/$prescriptionId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => PrescriptionItem.fromJson(e)).toList();
    } else {
      throw Exception('Không thể lấy chi tiết đơn thuốc');
    }
  }
}
