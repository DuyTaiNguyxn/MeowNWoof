import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/prescription.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/services/prescription_service.dart';
import 'package:meow_n_woof/views/medical_record/edit_medical_record.dart';
import 'package:meow_n_woof/views/prescription/prescription_detail.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';

class MedicalRecordDetailPage extends StatefulWidget {
  final Pet pet;
  final PetMedicalRecord record;

  const MedicalRecordDetailPage({
    super.key,
    required this.pet,
    required this.record,
  });

  @override
  State<MedicalRecordDetailPage> createState() => _MedicalRecordDetailPageState();
}

class _MedicalRecordDetailPageState extends State<MedicalRecordDetailPage> {
  PetMedicalRecord? _currentRecord;
  bool _isLoading = true;
  bool _hasDataChanged = false;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecordData();
    });
  }

  Future<void> _loadRecordData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_currentRecord?.id == null) {
        throw Exception('Medical Record ID is null. Cannot fetch details.');
      }

      final medicalRecordService = context.read<MedicalRecordService>();
      final fetchedRecord = await medicalRecordService.getMedicalRecordById(
        _currentRecord!.id!,
      );

      if (mounted) {
        setState(() {
          _currentRecord = fetchedRecord;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải chi tiết hồ sơ: ${e.toString()}')),
        );
        setState(() {
          _currentRecord = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToPrescription(int medicalRecordId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final prescriptionService = context.read<PrescriptionService>();

    if (authService.currentUser?.role != 'veterinarian') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ bác sĩ mới có thể tạo đơn thuốc.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final existingPrescription = await prescriptionService.getPrescriptionByRecordId(medicalRecordId);

      final hasPrescriptionChange = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionDetailPage(medicalRecordId: existingPrescription.medicalRecordId),
        ),
      );

      if (hasPrescriptionChange == true) {
        // xử lý khi quay lại có thay đổi
      }
    } catch (e) {
      // Nếu không có đơn thuốc → tạo mới
      try {
        final newPrescription = Prescription(
          medicalRecordId: _currentRecord!.id!,
          veterinarianId: authService.currentUser!.employeeId!,
          veterinarianNote: '',
          prescriptionDate: DateTime.now(),
        );

        await prescriptionService.createPrescription(newPrescription);

        final hasPrescriptionChange = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PrescriptionDetailPage(medicalRecordId: newPrescription.medicalRecordId),
          ),
        );

        if (hasPrescriptionChange == true) {
          // xử lý khi quay lại có thay đổi
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo đơn thuốc mới.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết hồ sơ'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentRecord == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết hồ sơ'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: Text('Không thể tải thông tin hồ sơ khám bệnh. Vui lòng thử lại.')),
      );
    }

    final PetMedicalRecord displayRecord = _currentRecord!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết hồ sơ - ${DateFormat('dd/MM/yyyy').format(displayRecord.recordDate.toLocal())}'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _hasDataChanged);
          },
        ),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: widget.pet.imageURL?.isNotEmpty == true
                          ? NetworkImage(widget.pet.imageURL!)
                          : const AssetImage('assets/images/logo_bg.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.pet.petName} - ${widget.pet.age} tuổi',
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
                          '${widget.pet.breed?.breedName ?? 'Không rõ'}  - ${widget.pet.weight != null ? '${widget.pet.weight!.toStringAsFixed(1)} kg' : 'Không rõ'}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: displayRecord.veterinarian?.avatarURL != null && displayRecord.veterinarian!.avatarURL!.isNotEmpty
                          ? NetworkImage(displayRecord.veterinarian!.avatarURL!) as ImageProvider<Object>
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
                            displayRecord.veterinarian?.fullName ?? 'Không rõ',
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
                            DateFormat('dd/MM/yyyy').format(displayRecord.recordDate.toLocal()),
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
                      displayRecord.symptoms?.isNotEmpty == true ? displayRecord.symptoms! : 'Chưa cập nhật',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Chẩn đoán ban đầu:',
                      displayRecord.preliminaryDiagnosis?.isNotEmpty == true ? displayRecord.preliminaryDiagnosis! : 'Chưa có',
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
                            displayRecord.finalDiagnosis?.isNotEmpty == true ? displayRecord.finalDiagnosis! : 'Chưa có',
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
                      displayRecord.treatmentMethod?.isNotEmpty == true ? displayRecord.treatmentMethod! : 'Chưa có',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Ghi chú bác sĩ:',
                      displayRecord.veterinarianNote?.isNotEmpty == true ? displayRecord.veterinarianNote! : 'Không có ghi chú',
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
                  onPressed: _isLoading || _currentRecord == null ? null : () async {
                    final bool? recordUpdated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditMedicalRecordScreen(
                          medicalRecord: displayRecord,
                          petId: widget.pet.petId!,
                          petName: widget.pet.petName,
                        ),
                      ),
                    );
                    if (recordUpdated == true) {
                      await _loadRecordData();
                      _hasDataChanged = true;
                    }
                  },
                  icon: const Icon(Icons.edit_note, color: Colors.white),
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
                  onPressed: _isLoading || _currentRecord == null
                      ? null
                      : () => _navigateToPrescription(_currentRecord!.id!),
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