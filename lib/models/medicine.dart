import 'package:meow_n_woof/models/medicine_type.dart';
import 'package:meow_n_woof/models/medicine_unit.dart';

class Medicine {
  final int medicineId;
  final String medicineName;
  final String? description;
  final int typeId;
  final int unitId;
  final String speciesUse;
  final int? stockQuantity;
  final DateTime receiptDate;
  final DateTime expiryDate;
  final String manufacturer;
  final double? price;
  final String? imageURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MedicineType? type;
  final MedicineUnit? unit;

  Medicine({
    required this.medicineId,
    required this.medicineName,
    this.description,
    required this.typeId,
    required this.unitId,
    required this.speciesUse,
    this.stockQuantity,
    required this.receiptDate,
    required this.expiryDate,
    required this.manufacturer,
    this.price,
    this.imageURL,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.unit,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicine_id'],
      medicineName: json['medicine_name'],
      description: json['description']?.toString(),
      typeId: json['type_id'],
      unitId: json['unit_id'],
      speciesUse: json['species_use'],
      stockQuantity: json['stock_quantity'],
      receiptDate: DateTime.tryParse(json['receipt_date'].toString()) ?? DateTime.now(),
      expiryDate: DateTime.tryParse(json['expiry_date'].toString()) ?? DateTime.now(),
      manufacturer: json['manufacturer'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      imageURL: json['imageURL']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      type: json['type'] != null ? MedicineType.fromJson(json['type']) : null,
      unit: json['unit'] != null ? MedicineUnit.fromJson(json['unit']) : null,
    );
  }
}