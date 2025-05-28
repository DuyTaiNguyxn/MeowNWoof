import 'package:flutter/material.dart';
import 'package:meow_n_woof/providers/vaccination_schedule_provider.dart';
import 'package:provider/provider.dart';

class ConfirmCreateVaccinationScheduleScreen extends StatelessWidget {
  const ConfirmCreateVaccinationScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<VaccinationScheduleProvider>(context);
    final selectedPet = scheduleProvider.selectedPet;
    final diseasePrevented = scheduleProvider.diseasePrevented;
    final selectedDate = scheduleProvider.selectedDate;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Xác nhận lịch hẹn tiêm phòng",
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
                  _buildInfoRow(Icons.vaccines, "Bệnh tiêm phòng", diseasePrevented ?? "Chưa chọn"),
                  Divider(thickness: 1.2),
                  _buildInfoRow(
                    Icons.access_time,
                    "Ngày tiêm",
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : "Chưa chọn",
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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