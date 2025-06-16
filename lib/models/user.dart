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
      employeeId: json['employee_id'] != null ? int.tryParse(json['employee_id'].toString()) : null,
      username: json['username'].toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
      avatarURL: json['avatarURL']?.toString(),
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