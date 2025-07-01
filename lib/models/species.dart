class Species {
  final int? speciesId;
  final String speciesName;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Species({
    this.speciesId,
    required this.speciesName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      speciesId: json['species_id'] as int?,
      speciesName: json['species_name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species_id': speciesId,
      'species_name': speciesName,
      'description': description,
    };
  }
}