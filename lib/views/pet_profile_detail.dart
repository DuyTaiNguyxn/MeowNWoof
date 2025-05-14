import 'package:flutter/material.dart';

class PetProfileDetail extends StatelessWidget {
  final String petName;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final double weight;
  final String imageUrl;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerAddress;

  const PetProfileDetail({
    super.key,
    required this.petName,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.ownerAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ thú cưng'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPetImage(),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Cập nhật thông tin
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Cập nhật thông tin',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Xem hồ sơ khám bệnh
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.medical_services, color: Colors.white),
                          label: const Text(
                            'Hồ sơ khám bệnh',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Gọi chủ nuôi
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'Gọi chủ nuôi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Thông tin thú cưng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 25, 81),
                ),
              ),
              const Divider(),
              _buildDetailRow('Tên:', petName),
              _buildDetailRow('Loài:', species),
              _buildDetailRow('Giống:', breed),
              _buildDetailRow('Giới tính:', gender),
              _buildDetailRow('Tuổi:', '$age tuổi'),
              _buildDetailRow('Cân nặng:', '${weight.toStringAsFixed(2)} kg'),
              const SizedBox(height: 20),
              const Text(
                'Thông tin chủ nuôi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 25, 81),
                ),
              ),
              const Divider(),
              _buildDetailRow('Họ tên:', ownerName),
              _buildDetailRow('SĐT:', ownerPhone),
              _buildDetailRow('Email:', ownerEmail),
              _buildDetailRow('Địa chỉ:', ownerAddress),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '(Không có thông tin)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/logo.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      )
          : Image.asset(
        'assets/images/logo.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

}
