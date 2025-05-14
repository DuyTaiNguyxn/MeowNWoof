import 'package:flutter/material.dart';

class PetProfileDetail extends StatelessWidget {
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final int age;

  const PetProfileDetail({
    super.key,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết hồ sơ pet'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tên:', petName),
            _buildDetailRow('Loài:', species),
            _buildDetailRow('Giống:', breed),
            _buildDetailRow('Giới tính:', gender),
            _buildDetailRow('Tuổi:', '$age tuổi'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // có thể chuyển sang trang cập nhật hồ sơ
                },
                child: const Text('Cập nhật thông tin'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
