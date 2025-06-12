// lib/models/breed.dart
import 'package:meow_n_woof/models/species.dart'; // Import Species model nếu bạn muốn nhúng

class Breed {
  final int? breedId; // breed_id
  final String breedName; // breed_name
  final String? description; // description
  final int speciesId; // species_id (khóa ngoại)

  // (Tùy chọn) Có thể thêm Species object nếu bạn muốn nhúng thông tin loài trực tiếp vào Breed model
  final Species? species; // Dùng để lưu trữ thông tin loài đầy đủ nếu API trả về

  final DateTime? createdAt; // created_at
  final DateTime? updatedAt; // updated_at

  Breed({
    this.breedId,
    required this.breedName,
    this.description,
    required this.speciesId,
    this.species, // Khởi tạo species
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor để tạo đối tượng Breed từ Map (JSON)
  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      breedId: json['breed_id'] as int?,
      breedName: json['breed_name'] as String,
      description: json['description'] as String?,
      speciesId: json['species_id'] as int,
      // Nếu API trả về thông tin loài được nhúng
      species: json['species'] != null
          ? Species.fromJson(json['species'] as Map<String, dynamic>)
          : null,
    );
  }

  // Phương thức để chuyển đổi Breed object thành Map (JSON) nếu cần gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'breed_id': breedId,
      'breed_name': breedName,
      'description': description,
      'species_id': speciesId,
      'species': species?.toJson(), // Đảm bảo species được gửi nếu có
    };
  }
}