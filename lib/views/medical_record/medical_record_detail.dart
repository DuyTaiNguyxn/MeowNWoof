import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/pet.dart';

class MedicalRecordDetailPage extends StatelessWidget {
  final Pet pet;
  final PetMedicalRecord record;

  const MedicalRecordDetailPage({
    super.key,
    required this.pet,
    required this.record,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '(Không có thông tin)',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            ' Chi tiết hồ sơ - ${DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal())}'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pet.petName} - ${pet.age} tuổi',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${pet.breed?.breedName ?? 'Không rõ'}  - ${pet.weight != null ? '${pet.weight!.toStringAsFixed(1)} kg' : 'Không rõ'}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // Card thông tin bác sĩ
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              // Bỏ margin ngang, chỉ giữ margin bottom
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: record.veterinarian?.avatarURL != null && record.veterinarian!.avatarURL!.isNotEmpty
                          ? NetworkImage(record.veterinarian!.avatarURL!) as ImageProvider<Object>
                          : const AssetImage('assets/images/avatar.png'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bác sĩ phụ trách:',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            record.veterinarian?.fullName ?? 'Không rõ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card chi tiết hồ sơ
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              // Bỏ margin ngang, chỉ giữ margin bottom
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày khám:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Triệu chứng:',
                      record.symptoms?.isNotEmpty == true ? record.symptoms! : 'Chưa cập nhật',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Chẩn đoán ban đầu:',
                      record.preliminaryDiagnosis?.isNotEmpty == true ? record.preliminaryDiagnosis! : 'Chưa có',
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chẩn đoán cuối cùng:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.finalDiagnosis?.isNotEmpty == true ? record.finalDiagnosis! : 'Chưa có',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Phương pháp điều trị:',
                      record.treatmentMethod?.isNotEmpty == true ? record.treatmentMethod! : 'Chưa có',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Ghi chú bác sĩ:',
                      record.veterinarianNote?.isNotEmpty == true ? record.veterinarianNote! : 'Không có ghi chú',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:() {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => EditMedicalRecordPage(),
                    //   ),
                    // );
                  },
                  icon: const Icon(Icons.note_alt_outlined, color: Colors.white),
                  label: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Len dơn thuoc
                  },
                  icon: const Icon(Icons.medication, color: Colors.white),
                  label: const Text('Lên đơn thuốc', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}