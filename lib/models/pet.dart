// Trong lib/models/pet.dart

import 'package:meow_n_woof/models/breed.dart';
import 'package:meow_n_woof/models/pet_owner.dart';
import 'package:meow_n_woof/models/species.dart';

class Pet {
  final int? petId;
  final String petName;
  final int? speciesId;
  final int? breedId;
  final int? age;
  final String? gender;
  final double? weight;
  final String? imageUrl;
  final int? ownerId;
  final PetOwner? owner;
  final Species? species;
  final Breed? breed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    this.petId,
    required this.petName,
    this.speciesId,
    this.breedId,
    this.age,
    this.gender,
    this.weight,
    this.imageUrl,
    this.ownerId,
    this.owner,
    this.species,
    this.breed,
    this.createdAt,
    this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      petId: json['pet_id'] != null ? int.tryParse(json['pet_id'].toString()) : null,
      petName: json['pet_name'] as String,
      speciesId: json['species_id'] != null ? int.tryParse(json['species_id'].toString()) : null,
      breedId: json['breed_id'] != null ? int.tryParse(json['breed_id'].toString()) : null,
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'] as String?,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      imageUrl: json['imageURL'] as String?,
      ownerId: json['owner_id'] != null ? int.tryParse(json['owner_id'].toString()) : null,
      owner: json['owner'] != null ? PetOwner.fromJson(json['owner'] as Map<String, dynamic>) : null,
      species: json['species'] != null ? Species.fromJson(json['species'] as Map<String, dynamic>) : null,
      breed: json['breed'] != null ? Breed.fromJson(json['breed'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_name': petName,
      'species_id': speciesId,
      'breed_id': breedId,
      'age': age,
      'gender': gender,
      'weight': weight,
      'imageURL': imageUrl,
      'owner': owner?.toJson(),
    };
  }
}