import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/pet/edit_pet_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class PetProfileDetail extends StatelessWidget {
  final Pet pet;

  const PetProfileDetail({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ thú cưng'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPetImage(),
            const SizedBox(height: 20),
            const Text('Thông tin thú cưng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Tên:', pet.name),
            _buildDetailRow('Loài:', pet.species),
            _buildDetailRow('Giống:', pet.breed),
            _buildDetailRow('Giới tính:', pet.gender),
            _buildDetailRow('Tuổi:', '${pet.age} tuổi'),
            _buildDetailRow('Cân nặng:', '${pet.weight.toStringAsFixed(2)} kg'),
            const SizedBox(height: 20),
            const Text('Thông tin chủ nuôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Họ tên:', pet.ownerName),
            _buildDetailRow('SĐT:', pet.ownerPhone),
            _buildDetailRow('Email:', pet.ownerEmail),
            _buildDetailRow('Địa chỉ:', pet.ownerAddress),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPetProfilePage(pet: pet),
                          ),
                        );
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicalRecordListPage(pet: pet),
                          ),
                        );
                      },
                      icon: const Icon(Icons.medical_services, color: Colors.white),
                      label: const Text('Hồ sơ khám bệnh', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                        final phoneUri = Uri(scheme: 'tel', path: pet.ownerPhone);
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể mở trình gọi điện')),
                          );
                        }
                      },
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text('Gọi chủ nuôi', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isNotEmpty ? value : '(Không có thông tin)')),
        ],
      ),
    );
  }

  Widget _buildPetImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: pet.imageUrl.isNotEmpty
          ? Image.network(pet.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover)
          : Image.asset('assets/images/logo_bg.png', height: 200, width: double.infinity, fit: BoxFit.cover),
    );
  }
}
