import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/models/pet.dart';

class Appointment {
  final int? id;
  final int petId;
  final DateTime appointmentDatetime;
  final int employeeId;
  final int veterinarianId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? veterinarian;
  final Pet? pet;

  Appointment({
    this.id,
    required this.petId,
    required this.appointmentDatetime,
    required this.employeeId,
    required this.veterinarianId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.veterinarian,
    this.pet,
  });

  Appointment copyWith({
    int? id,
    int? petId,
    DateTime? appointmentDatetime,
    int? employeeId,
    int? veterinarianId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? veterinarian,
    Pet? pet,
  }) {
    return Appointment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      appointmentDatetime: appointmentDatetime ?? this.appointmentDatetime,
      employeeId: employeeId ?? this.employeeId,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      veterinarian: veterinarian ?? this.veterinarian,
      pet: pet ?? this.pet,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['appointment_id'] != null ? int.tryParse(json['appointment_id'].toString()) : null,
      petId: json['pet_id'] as int,
      appointmentDatetime: DateTime.parse(json['appointment_datetime'].toString()),
      employeeId: json['employee_id'] as int,
      veterinarianId: json['veterinarian_id'] as int,
      status: json['status'].toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,

      veterinarian: json['veterinarian'] != null
          ? User.fromJson(json['veterinarian'] as Map<String, dynamic>)
          : null,

      pet: json['pet'] != null
          ? Pet.fromJson(json['pet'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'appointment_datetime': appointmentDatetime.toIso8601String(),
      'employee_id': employeeId,
      'veterinarian_id': veterinarianId,
      'status': status,
    };
  }
}