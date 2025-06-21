import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/appointment.dart';
import 'package:meow_n_woof/services/auth_service.dart';

class AppointmentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api/appointments';

  final AuthService _authService;

  AppointmentService(this._authService);

  Future<Map<String, String>> _getHeadersWithAuth() async {
    final String? token = await _authService.getToken();
    print('[AppointmentService] Token retrieved: ${token != null ? "Token exists" : "Token is NULL"}');
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Appointment>> getAllAppointments() async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      // print('[AppointmentService] getAllAppointments Status: ${response.statusCode}');
      // print('[AppointmentService] getAllAppointments Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> appointmentJsonList = responseBody['data'];
        return appointmentJsonList.map((json) => Appointment.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to load appointments: ${errorBody['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in getAllAppointments (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<Appointment> getAppointmentById(int id) async {
    try {
      final headers = await _getHeadersWithAuth();
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );

      print('[AppointmentService] getAppointmentById Status: ${response.statusCode}');
      print('[AppointmentService] getAppointmentById Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Appointment.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found with ID: $id');
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to load appointment: ${errorBody['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in getAppointmentById (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final headers = await _getHeadersWithAuth();
      final requestBody = json.encode(appointment.toJson());

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: requestBody,
      );

      // print('[AppointmentService] createAppointment Status: ${response.statusCode}');
      // print('[AppointmentService] createAppointment Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map<String, dynamic>) {
          return Appointment.fromJson(responseBody['data']);
        } else {
          throw Exception('Invalid response format: "data" field missing or not a map.');
        }
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        final String errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to create appointment: $errorMessage (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in createAppointment (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<Appointment> updateAppointment(int id, Appointment appointment) async {
    try {
      final headers = await _getHeadersWithAuth();
      final requestBody = json.encode(appointment.toJson());

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
        body: requestBody,
      );

      print('[AppointmentService] updateAppointment Status: ${response.statusCode}');
      print('[AppointmentService] updateAppointment Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Appointment.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found for update with ID: $id');
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to update appointment: ${errorBody['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in updateAppointment (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

  Future<Appointment> updateAppointmentStatus(int id, String newStatus) async {
    try {
      final headers = await _getHeadersWithAuth();
      final requestBody = json.encode({'status': newStatus});

      print('[AppointmentService] requestBody: $requestBody');
      final response = await http.put(
        Uri.parse('$_baseUrl/status/$id'),
        headers: headers,
        body: requestBody,
      );

      // print('[AppointmentService] updateAppointmentStatus Status: ${response.statusCode}');
      // print('[AppointmentService] updateAppointmentStatus Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return Appointment.fromJson(responseBody['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found for status update with ID: $id');
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception('Failed to update appointment status: ${errorBody['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error in updateAppointmentStatus (Service Catch Block): $e');
      throw Exception('Failed to connect to server or process data: $e');
    }
  }

}