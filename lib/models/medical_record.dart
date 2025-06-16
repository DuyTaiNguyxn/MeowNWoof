import 'package:meow_n_woof/models/user.dart';

class PetMedicalRecord {
  final int? id;
  final int petId;
  final DateTime recordDate;
  final String? symptoms;
  final String? preliminaryDiagnosis;
  final String finalDiagnosis;
  final String? treatmentMethod;
  final int veterinarianId;
  final String? veterinarianNote;
  final User? veterinarian;

  PetMedicalRecord({
    this.id,
    required this.petId,
    required this.recordDate,
    this.symptoms,
    this.preliminaryDiagnosis,
    required this.finalDiagnosis,
    this.treatmentMethod,
    required this.veterinarianId,
    this.veterinarianNote,
    this.veterinarian,
  });

  factory PetMedicalRecord.fromJson(Map<String, dynamic> json) {
    return PetMedicalRecord(
      id: json['medical_record_id'] != null ? int.tryParse(json['medical_record_id'].toString()) : null,
      petId: json['pet_id'] as int,
      recordDate: DateTime.parse(json['record_date'].toString()),
      symptoms: json['symptoms']?.toString(),
      preliminaryDiagnosis: json['preliminary_diagnosis']?.toString(),
      finalDiagnosis: json['final_diagnosis'].toString(),
      treatmentMethod: json['treatment_method']?.toString(),
      veterinarianId: json['veterinarian_id'] as int,
      veterinarianNote: json['veterinarian_note']?.toString(),
      veterinarian: json['veterinarian'] != null
          ? User.fromJson(json['veterinarian'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'record_date': recordDate.toIso8601String(),
      'symptoms': symptoms,
      'preliminary_diagnosis': preliminaryDiagnosis,
      'final_diagnosis': finalDiagnosis,
      'treatment_method': treatmentMethod,
      'veterinarian_id': veterinarianId,
      'veterinarian_note': veterinarianNote,
    };
  }
}