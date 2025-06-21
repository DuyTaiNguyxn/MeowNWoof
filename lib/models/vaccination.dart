import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/models/pet.dart';

class Vaccination {
  final int vaccinationId;
  final int petId;
  final DateTime vaccinationDatetime;
  final String diseasePrevented;
  final int vaccineId;
  final int employeeId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pet? pet;
  final Medicine? vaccine;

  Vaccination({
    required this.vaccinationId,
    required this.petId,
    required this.vaccinationDatetime,
    required this.diseasePrevented,
    required this.vaccineId,
    required this.employeeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pet,
    this.vaccine,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinationId: json['vaccination_id'],
      petId: json['pet_id'],
      vaccinationDatetime: DateTime.parse(json['vaccination_datetime']),
      diseasePrevented: json['disease_prevented'],
      vaccineId: json['vaccine_id'],
      employeeId: json['employee_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pet: json['pet'] != null ? Pet.fromJson(json['pet']) : null,
      vaccine: json['vaccine'] != null ? Medicine.fromJson(json['vaccine']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'vaccination_datetime': vaccinationDatetime.toIso8601String(),
      'disease_prevented': diseasePrevented,
      'vaccine_id': vaccineId,
      'employee_id': employeeId,
      'status': status,
    };
  }
}