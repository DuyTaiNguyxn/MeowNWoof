import 'package:meow_n_woof/models/prescription_item.dart';

class Prescription {
  final int? prescriptionId;
  final int medicalRecordId;
  final int veterinarianId;
  final String? veterinarianNote;
  final DateTime? prescriptionDate;
  final List<PrescriptionItem>? items;

  Prescription({
    this.prescriptionId,
    required this.medicalRecordId,
    required this.veterinarianId,
    this.veterinarianNote,
    this.prescriptionDate,
    this.items,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    List<PrescriptionItem>? itemsList;

    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => PrescriptionItem.fromJson(item))
          .toList();
    }

    return Prescription(
      prescriptionId: json['prescription_id'] != null ? int.tryParse(json['prescription_id'].toString()) : null,
      medicalRecordId: json['medical_record_id'],
      veterinarianId: json['veterinarian_id'],
      veterinarianNote: json['veterinarian_note']?.toString(),
      prescriptionDate: json['prescription_date'] != null
          ? DateTime.tryParse(json['prescription_date'].toString())
          : null,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medical_record_id': medicalRecordId,
      'veterinarian_id': veterinarianId,
      'veterinarian_note': veterinarianNote,
      'prescription_date': prescriptionDate?.toIso8601String(),
    };
  }

  Prescription copyWith({
    int? prescriptionId,
    int? medicalRecordId,
    int? veterinarianId,
    String? veterinarianNote,
    DateTime? prescriptionDate,
    List<PrescriptionItem>? items,
  }) {
    return Prescription(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicalRecordId: medicalRecordId ?? this.medicalRecordId,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      veterinarianNote: veterinarianNote ?? this.veterinarianNote,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      items: items ?? this.items,
    );
  }
}