class PrescriptionItem {
  final int itemId;
  final int prescriptionId;
  final int medicineId;
  final int quantity;
  final String dosage;
  final String? medicineName;
  final String? imageUrl;

  PrescriptionItem({
    required this.itemId,
    required this.prescriptionId,
    required this.medicineId,
    required this.quantity,
    required this.dosage,
    this.medicineName,
    this.imageUrl,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      itemId: json['item_id'],
      prescriptionId: json['prescription_id'],
      medicineId: json['medicine_id'],
      quantity: json['quantity'],
      dosage: json['dosage'],
      medicineName: json['medicine_name']?.toString(),
      imageUrl: json['imageURL']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'medicine_id': medicineId,
      'quantity': quantity,
      'dosage': dosage,
    };
  }
}
