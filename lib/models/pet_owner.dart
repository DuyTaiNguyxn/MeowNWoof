// Trong lib/models/pet_owner.dart (Nếu owner_id có thể là null)
class PetOwner {
  final int? ownerId; // Đổi thành nullable nếu có thể null
  final String ownerName;
  final String phone;
  final String? email;
  final String? address;

  PetOwner({
    this.ownerId, // Bỏ required nếu đổi thành nullable
    required this.ownerName,
    required this.phone,
    this.email,
    this.address,
  });

  factory PetOwner.fromJson(Map<String, dynamic> json) {
    return PetOwner(
      ownerId: json['owner_id'] != null ? int.tryParse(json['owner_id'].toString()) : null,
      ownerName: json['owner_name'].toString(),
      phone: json['phone'].toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_name': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}