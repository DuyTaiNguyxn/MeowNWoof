// lib/models/breed.dart
import 'package:meow_n_woof/models/species.dart';

class Breed {
  final int? breedId;
  final String breedName;
  final String? description;
  final int speciesId;
  final Species? species;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Breed({
    this.breedId,
    required this.breedName,
    this.description,
    required this.speciesId,
    this.species,
    this.createdAt,
    this.updatedAt,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      breedId: json['breed_id'] as int?,
      breedName: json['breed_name'].toString(),
      description: json['description']?.toString(),
      speciesId: json['species_id'] as int,
      species: json['species'] != null
          ? Species.fromJson(json['species'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breed_id': breedId,
      'breed_name': breedName,
      'description': description,
      'species_id': speciesId,
      'species': species?.toJson(),
    };
  }
}