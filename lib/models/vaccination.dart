import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/models/pet.dart';

class Vaccination {
  final int? vaccinationId;
  final int petId;
  final DateTime vaccinationDatetime;
  final String diseasePrevented;
  final int vaccineId;
  final int employeeId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Pet? pet;
  final Medicine? vaccine;

  Vaccination({
    this.vaccinationId,
    required this.petId,
    required this.vaccinationDatetime,
    required this.diseasePrevented,
    required this.vaccineId,
    required this.employeeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.pet,
    this.vaccine,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinationId: json['vaccination_id'] != null ? int.tryParse(json['vaccination_id'].toString()) : null,
      petId: json['pet_id'],
      vaccinationDatetime: DateTime.parse(json['vaccination_datetime']),
      diseasePrevented: json['disease_prevented'],
      vaccineId: json['vaccine_id'],
      employeeId: json['employee_id'],
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
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

  Vaccination copyWith({
    int? vaccinationId,
    int? petId,
    DateTime? vaccinationDatetime,
    String? diseasePrevented,
    int? vaccineId,
    int? employeeId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Pet? pet,
    Medicine? vaccine,
  }) {
    return Vaccination(
      vaccinationId: vaccinationId ?? this.vaccinationId,
      petId: petId ?? this.petId,
      vaccinationDatetime: vaccinationDatetime ?? this.vaccinationDatetime,
      diseasePrevented: diseasePrevented ?? this.diseasePrevented,
      vaccineId: vaccineId ?? this.vaccineId,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pet: pet ?? this.pet,
      vaccine: vaccine ?? this.vaccine,
    );
  }
}