class MedicineUnit {
  final int? unitId;
  final String unitName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicineUnit({
    this.unitId,
    required this.unitName,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicineUnit.fromJson(Map<String, dynamic> json) {
    return MedicineUnit(
      unitId: json['medicine_unit_id'] as int?,
      unitName: json['unit_name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_unit_id': unitId,
      'unit_name': unitName,
    };
  }
}