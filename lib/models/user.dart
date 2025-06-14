import 'package:intl/intl.dart';

class User {
  final int? employeeId;
  final String username;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  final String? avatarURL;
  final DateTime? birth;

  User({
    this.employeeId,
    required this.username,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.avatarURL,
    this.birth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      employeeId: json['employee_id'] as int?,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String?,
      avatarURL: json['avatarURL'] as String?,
      birth: json['birth'] != null ? DateTime.parse(json['birth']).toLocal() : null,
    );
  }

  // Phương thức để chuyển đổi User object thành Map (JSON) nếu cần gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'avatarURL': avatarURL,
      'birth': birth != null ? DateFormat('yyyy-MM-dd').format(birth!) : null,
    };
  }
}