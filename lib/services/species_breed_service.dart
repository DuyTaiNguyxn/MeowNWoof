// lib/services/species_breed_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/species.dart';
import 'package:meow_n_woof/models/breed.dart';

class SpeciesBreedService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Species>> getSpecies() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/species'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Species.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load species');
      }
    } catch (e) {
      throw Exception('Error fetching species: $e');
    }
  }

  Future<List<Breed>> getBreeds() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/breeds'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Breed.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load breeds');
      }
    } catch (e) {
      throw Exception('Error fetching breeds: $e');
    }
  }

  Future<List<Breed>> getBreedsBySpeciesId(int speciesId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/breeds/by-species/$speciesId'));
      if (response.statusCode == 200) {
        final List<dynamic> breedJsonList = json.decode(response.body);
        return breedJsonList.map((json) => Breed.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load breeds by species ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching breeds: $e');
    }
  }
}