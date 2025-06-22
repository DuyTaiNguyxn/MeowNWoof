import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/medicine.dart';

class MedicineService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/medicines';

  Future<List<Medicine>> getAllMedicines() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medicines. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicines: $e');
      throw Exception('Failed to connect to the server or an unexpected error occurred: $e');
    }
  }

  Future<Medicine> getMedicineById(int id) async {
    try {
      final String url = '$_baseUrl/$id';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return Medicine.fromJson(jsonMap);
      } else if (response.statusCode == 404) {
        throw Exception('Medicine with ID $id not found.');
      } else {
        throw Exception('Failed to load medicine by ID $id. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicine by ID $id: $e');
      throw Exception('Failed to connect to the server or an unexpected error occurred: $e');
    }
  }
}