class PetMedicalRecord {
  final int? id;
  final int petId;
  final DateTime recordDate;
  final String symptoms;
  final String preliminaryDiagnosis;
  final String finalDiagnosis;
  final String treatmentMethod;
  final int? veterinarianId;
  final String veterinarianNotes;

  PetMedicalRecord({
    this.id,
    required this.petId,
    required this.recordDate,
    required this.symptoms,
    required this.preliminaryDiagnosis,
    required this.finalDiagnosis,
    required this.treatmentMethod,
    this.veterinarianId,
    required this.veterinarianNotes,
  });

  factory PetMedicalRecord.fromJson(Map<String, dynamic> json) {
    return PetMedicalRecord(
      id: json['medical_record_id'],
      petId: json['pet_id'],
      recordDate: DateTime.parse(json['record_date']),
      symptoms: json['symptoms'] ?? '',
      preliminaryDiagnosis: json['preliminary_diagnosis'] ?? '',
      finalDiagnosis: json['final_diagnosis'] ?? '',
      treatmentMethod: json['treatment_method'] ?? '',
      veterinarianId: json['veterinarian_id'],
      veterinarianNotes: json['veterinarian_notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medical_record_id': id,
      'pet_id': petId,
      'record_date': recordDate.toIso8601String(),
      'symptoms': symptoms,
      'preliminary_diagnosis': preliminaryDiagnosis,
      'final_diagnosis': finalDiagnosis,
      'treatment_method': treatmentMethod,
      'veterinarian_id': veterinarianId,
      'veterinarian_notes': veterinarianNotes,
    };
  }
}
