import 'package:meow_n_woof/models/medicine_type.dart';
import 'package:meow_n_woof/models/medicine_unit.dart';

class Medicine {
  final int medicineId;
  final String medicineName;
  final String? description;
  final int? typeId;
  final int? unitId;
  final String? speciesUse;
  final int? stockQuantity;
  final DateTime? receiptDate;
  final DateTime? expiryDate;
  final String? manufacturer;
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
    this.typeId,
    this.unitId,
    this.speciesUse,
    this.stockQuantity,
    this.receiptDate,
    this.expiryDate,
    this.manufacturer,
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
      medicineName: json['medicine_name'] ?? '',
      description: json['description']?.toString(),
      typeId: json['type_id'] is int ? json['type_id'] : int.tryParse(json['type_id']?.toString() ?? ''),
      unitId: json['unit_id'] is int ? json['unit_id'] : int.tryParse(json['unit_id']?.toString() ?? ''),
      speciesUse: json['species_use']?.toString(),
      stockQuantity: json['stock_quantity'] is int ? json['stock_quantity'] : int.tryParse(json['stock_quantity']?.toString() ?? ''),
      receiptDate: json['receipt_date'] != null ? DateTime.tryParse(json['receipt_date'].toString()) : null,
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
      manufacturer: json['manufacturer']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      imageURL: json['imageURL']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      type: json['type'] != null ? MedicineType.fromJson(json['type']) : null,
      unit: json['unit'] != null ? MedicineUnit.fromJson(json['unit']) : null,
    );
  }
}