class Species {
  final int? speciesId; // species_id
  final String speciesName; // species_name
  final String? description; // description
  final DateTime? createdAt; // created_at
  final DateTime? updatedAt; // updated_at

  Species({
    this.speciesId,
    required this.speciesName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor để tạo đối tượng Species từ Map (JSON)
  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      speciesId: json['species_id'] as int?,
      speciesName: json['species_name'] as String,
      description: json['description'] as String?,
    );
  }

  // Phương thức để chuyển đổi Species object thành Map (JSON) nếu cần gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'species_id': speciesId,
      'species_name': speciesName,
      'description': description,
    };
  }
}