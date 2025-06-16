import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/pet.dart'; // Đảm bảo đã import model Pet

class MedicalRecordDetailPage extends StatelessWidget {
  final Pet pet; // Thông tin về thú cưng
  final PetMedicalRecord record; // Thông tin hồ sơ khám bệnh

  const MedicalRecordDetailPage({
    super.key,
    required this.pet,
    required this.record,
  });

  // Helper function để xây dựng hàng chi tiết tương tự như PetProfileDetail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130, // Điều chỉnh độ rộng của label để phù hợp với các nhãn dài hơn
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '(Không có thông tin)',
              style: const TextStyle(
                fontSize: 16, // Giữ kích thước font giống với label hoặc điều chỉnh nếu cần
              ),
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
        title: Text(' Chi tiết hồ sơ - ${DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal())}'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20.0), // Tăng khoảng cách dưới
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
                        // Có thể thêm icon giới tính nếu có
                        // Icon(pet.gender == 'Male' ? Icons.male : Icons.female, color: Colors.grey),
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

            // --- THÔNG TIN BÁC SĨ (Avatar - Tên Bác sĩ) ---
            // Trong medical_record_detail_page.dart, tìm Card chứa thông tin bác sĩ
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row( // <-- THAY ĐỔI TỪ COLUMN SANG ROW Ở ĐÂY
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      // Nếu có avatarURL của bác sĩ, hiển thị ở đây
                      backgroundImage: record.veterinarian?.avatarURL != null && record.veterinarian!.avatarURL!.isNotEmpty
                          ? NetworkImage(record.veterinarian!.avatarURL!)
                          : null,
                      child: record.veterinarian?.avatarURL == null || record.veterinarian!.avatarURL!.isEmpty
                          ? Icon(Icons.person_pin, size: 40, color: Colors.blue.shade700)
                          : null,
                    ),
                    const SizedBox(width: 16), // <-- SizedBox width giờ đã có tác dụng
                    Expanded( // <-- Dùng Expanded để Column text chiếm hết không gian còn lại
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

            const Divider(height: 20, thickness: 1),

            _buildDetailRow(
              'Ngày khám:',
              DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal()),
            ),
            _buildDetailRow(
              'Triệu chứng:',
              record.symptoms?.isNotEmpty == true ? record.symptoms! : 'Chưa cập nhật',
            ),
            _buildDetailRow(
              'Chẩn đoán ban đầu:',
              record.preliminaryDiagnosis?.isNotEmpty == true ? record.preliminaryDiagnosis! : 'Chưa có',
            ),
            _buildDetailRow(
              'Chẩn đoán cuối cùng:',
              record.finalDiagnosis?.isNotEmpty == true ? record.finalDiagnosis! : 'Chưa có',
            ),
            _buildDetailRow(
              'Phương pháp điều trị:',
              record.treatmentMethod?.isNotEmpty == true ? record.treatmentMethod! : 'Chưa có',
            ),
            _buildDetailRow(
              'Ghi chú bác sĩ:',
              record.veterinarianNote?.isNotEmpty == true ? record.veterinarianNote! : 'Không có ghi chú',
            ),
          ],
        ),
      ),
    );
  }
}