import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medicine.dart';
import 'package:intl/intl.dart';

class MedicineDetailPage extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailPage({
    super.key,
    required this.medicine,
  });

  bool _isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expirationDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expirationDay.isBefore(today);
  }

  String formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date.toLocal()) : 'Chưa rõ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.medicineName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicineImage(medicine),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.medicineName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow('Mô tả:', medicine.description ?? 'Không có'),
                    _buildTypeRow('Loại:', medicine.type?.typeName ?? 'Chưa cập nhật'),
                    _buildDetailRow('Đơn vị:', medicine.unit?.unitName ?? 'Chưa cập nhật'),
                    _buildDetailRow('Dùng cho:', medicine.speciesUse ?? 'Chưa cập nhật'),
                    _buildDetailRow('Số lượng còn:', medicine.stockQuantity?.toString() ?? 'Chưa rõ'),
                    _buildDetailRow('Ngày nhập:', formatDate(medicine.receiptDate)),
                    _buildExpiryDateRow('Ngày hết hạn:', medicine.expiryDate),
                    _buildDetailRow('Nhà sản xuất:', medicine.manufacturer ?? 'Chưa cập nhật'),
                    _buildDetailRow(
                      'Giá:',
                      medicine.price != null
                          ? '${medicine.price!.toStringAsFixed(0)} VNĐ'
                          : 'Chưa cập nhật',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineImage(Medicine medicine) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: medicine.imageURL != null && medicine.imageURL!.isNotEmpty
          ? Image.network(medicine.imageURL!, height: 300, width: double.infinity, fit: BoxFit.cover)
          : Image.asset('assets/images/logo_bg.png', height: 300, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
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

  Widget _buildTypeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryDateRow(String label, DateTime? expiryDate) {
    final isExpired = _isExpired(expiryDate);
    final dateString = formatDate(expiryDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              dateString,
              style: TextStyle(
                fontSize: 16,
                color: isExpired ? Colors.red : Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
