import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicineDetailPage extends StatelessWidget {
  final String name;
  final String description;
  final String type;
  final String unit;
  final String speciesUse;
  final int stockQuantity;
  final DateTime receiptDate;
  final DateTime expiryDate;
  final String manufacturer;
  final double? price;
  final String imageUrl;

  const MedicineDetailPage({
    super.key,
    required this.name,
    required this.description,
    required this.type,
    required this.unit,
    required this.speciesUse,
    required this.stockQuantity,
    required this.receiptDate,
    required this.expiryDate,
    required this.manufacturer,
    required this.price,
    required this.imageUrl,
  });

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String _formatPrice(double? p) => p != null ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(p) : 'Không có';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thuốc'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMedicineImage(),
            const SizedBox(height: 20),
            const Text(
              'Thông tin thuốc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailRow('Tên thuốc:', name),
            _buildDetailRow('Loại:', type),
            _buildDetailRow('Dạng:', unit),
            _buildDetailRow('Dùng cho:', speciesUse),
            _buildDetailRow('Số lượng tồn:', '$stockQuantity'),
            _buildDetailRow('Ngày nhập:', _formatDate(receiptDate)),
            _buildDetailRow(
              'Hạn sử dụng:',
              _formatDate(expiryDate),
              isExpired: expiryDate.isBefore(DateTime.now()),
            ),
            _buildDetailRow('Nhà sản xuất:', manufacturer),
            _buildDetailRow('Giá:', _formatPrice(price)),
            const SizedBox(height: 16),
            const Text(
              'Mô tả',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description.isNotEmpty ? description : '(Không có mô tả)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isExpired ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineImage() {
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
                  'assets/images/logo_bg.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              'assets/images/logo_bg.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }
}
