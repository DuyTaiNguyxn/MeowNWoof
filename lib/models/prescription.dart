import 'package:meow_n_woof/models/prescription_item.dart';

class Prescription {
  final int prescriptionId;
  final int medicalRecordId;
  final int veterinarianId;
  final String? veterinarianNote;
  final String? prescriptionDate;
  final List<PrescriptionItem>? items;

  Prescription({
    required this.prescriptionId,
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
      prescriptionId: json['prescription_id'],
      medicalRecordId: json['medical_record_id'],
      veterinarianId: json['veterinarian_id'],
      veterinarianNote: json['veterinarian_note']?.toString(),
      prescriptionDate: json['prescription_date']?.toString(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medical_record_id': medicalRecordId,
      'veterinarian_id': veterinarianId,
      'veterinarian_note': veterinarianNote,
      'prescription_date': prescriptionDate,
    };
  }
}
