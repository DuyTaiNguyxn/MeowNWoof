class User {
  final int? employeeId;
  final String username;
  final String fullName;
  final String? email;
  final String phone;
  final String? address;
  final String? role;
  final String? avatarURL;
  final DateTime birth;

  User({
    this.employeeId,
    required this.username,
    required this.fullName,
    this.email,
    required this.phone,
    this.address,
    this.role,
    this.avatarURL,
    required this.birth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final DateTime rawBirth = DateTime.parse(json['birth']);
    final DateTime localRawBirth = rawBirth.toLocal();
    DateTime parsedBirth = DateTime(localRawBirth.year, localRawBirth.month, localRawBirth.day);
    return User(
      employeeId: json['employee_id'] != null ? int.tryParse(json['employee_id'].toString()) : null,
      username: json['username'].toString(),
      fullName: json['full_name'].toString(),
      email: json['email']?.toString(),
      phone: json['phone'].toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
      avatarURL: json['avatarURL']?.toString(),
      birth: parsedBirth,
    );
  }

  Map<String, dynamic> toJson() {
    String birthStringForSave = birth.toIso8601String();
    return {
      'employee_id': employeeId,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'avatarURL': avatarURL,
      'birth': birthStringForSave,
    };
  }
}