import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/prescription.dart';
import 'package:meow_n_woof/services/prescription_service.dart';
import 'package:provider/provider.dart';

class PrescriptionDetailPage extends StatefulWidget {
  final int medicalRecordId;

  const PrescriptionDetailPage({super.key, required this.medicalRecordId});

  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  Prescription? _prescription;
  bool _isLoading = true;

  late PrescriptionService _prescriptionService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _prescriptionService = Provider.of<PrescriptionService>(context, listen: false);
      await _fetchPrescription();
    });
  }

  Future<void> _fetchPrescription() async {
    try {
      final data = await _prescriptionService.getPrescriptionByRecordId(widget.medicalRecordId);
      if (mounted) setState(() => _prescription = data);
    } catch (_) {
      setState(() => _prescription = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _prescription?.items?.isEmpty ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn thuốc'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescription == null
          ? const Center(child: Text('Không tìm thấy đơn thuốc.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú của bác sĩ:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _prescription?.veterinarianNote ?? 'Không có',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ..._prescription!.items!.map(
                  (item) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset('assets/images/logo_bg.png',
                      width: 48, height: 48),
                  title: Text(item.medicineName ?? 'Tên thuốc không rõ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Số lượng: '),
                            TextSpan(text: '${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Liều dùng: '),
                            TextSpan(text: item.dosage, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isEmpty
              ? SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: mở trang tạo đơn thuốc
              },
              label: const Text('Tạo đơn thuốc',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
              : Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: mở trang chỉnh sửa đơn thuốc
                  },
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  label: const Text('Chỉnh sửa',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: xác nhận xoá đơn thuốc
                  },
                  icon:
                  const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Xoá đơn thuốc',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
