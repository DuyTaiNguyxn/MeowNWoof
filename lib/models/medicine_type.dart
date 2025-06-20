class MedicineType {
  final int? typeId;
  final String typeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicineType({
    this.typeId,
    required this.typeName,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicineType.fromJson(Map<String, dynamic> json) {
    return MedicineType(
      typeId: json['medicine_type_id'] as int?,
      typeName: json['type_name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_type_id': typeId,
      'type_name': typeName,
    };
  }
}