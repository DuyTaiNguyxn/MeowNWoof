import 'package:flutter/material.dart';

class ConfirmCreateAppointmentScreen extends StatelessWidget {
  final String? selectedPet;
  final String? selectedVeterinarian;
  final DateTime? selectedDateTime;

  const ConfirmCreateAppointmentScreen({
    Key? key,
    required this.selectedPet,
    required this.selectedVeterinarian,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Xác nhận lịch hẹn",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.pets, "Pet", selectedPet ?? "Chưa chọn"),
                  Divider(thickness: 1.2),
                  _buildInfoRow(Icons.medical_services, "Bác sĩ", selectedVeterinarian ?? "Chưa chọn"),
                  Divider(thickness: 1.2),
                  _buildInfoRow(Icons.access_time, "Thời gian",
                      selectedDateTime != null
                          ? "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} lúc ${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}"
                          : "Chưa chọn"
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // khoảng cách giữa các dòng
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.lightBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
