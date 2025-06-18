import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/medical_record.dart';

class EditMedicalRecordScreen extends StatefulWidget {
  final PetMedicalRecord medicalRecord;
  final int petId;
  final String petName;

  const EditMedicalRecordScreen({
    super.key,
    required this.medicalRecord,
    required this.petId,
    required this.petName,
  });

  @override
  State<EditMedicalRecordScreen> createState() => _EditMedicalRecordScreenState();
}

class _EditMedicalRecordScreenState extends State<EditMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _symptomsController;
  late TextEditingController _preliminaryDiagnosisController;
  late TextEditingController _finalDiagnosisController;
  late TextEditingController _treatmentMethodController;
  late TextEditingController _veterinarianNoteController;

  late DateTime _recordDate;
  User? _selectedVeterinarian;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _symptomsController = TextEditingController(text: widget.medicalRecord.symptoms);
    _preliminaryDiagnosisController = TextEditingController(text: widget.medicalRecord.preliminaryDiagnosis);
    _finalDiagnosisController = TextEditingController(text: widget.medicalRecord.finalDiagnosis);
    _treatmentMethodController = TextEditingController(text: widget.medicalRecord.treatmentMethod);
    _veterinarianNoteController = TextEditingController(text: widget.medicalRecord.veterinarianNote);

    _recordDate = widget.medicalRecord.recordDate.toLocal();
    _selectedVeterinarian = widget.medicalRecord.veterinarian;
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _preliminaryDiagnosisController.dispose();
    _finalDiagnosisController.dispose();
    _treatmentMethodController.dispose();
    _veterinarianNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _recordDate) {
      setState(() {
        _recordDate = picked;
      });
    }
  }

  void _navigateToVeterinarianSelection() async {
    final User? selectedVet = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VeterinarianSelectionWidget(
          selectedVet: _selectedVeterinarian,
          onVeterinarianSelected: (User vet) {
            Navigator.pop(context, vet);
          },
        ),
      ),
    );

    if (selectedVet != null) {
      setState(() {
        _selectedVeterinarian = selectedVet;
      });
    }
  }

  // Hàm gửi dữ liệu cập nhật đến backend
  Future<void> _updateMedicalRecord() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVeterinarian == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn bác sĩ thú y.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final updatedRecord = PetMedicalRecord(
          id: widget.medicalRecord.id,
          petId: widget.petId,
          recordDate: _recordDate,
          symptoms: _symptomsController.text,
          preliminaryDiagnosis: _preliminaryDiagnosisController.text,
          finalDiagnosis: _finalDiagnosisController.text,
          treatmentMethod: _treatmentMethodController.text,
          veterinarianId: _selectedVeterinarian!.employeeId!,
          veterinarianNote: _veterinarianNoteController.text,
        );

        final medicalRecordService = context.read<MedicalRecordService>();
        await medicalRecordService.updateMedicalRecord(updatedRecord);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật hồ sơ khám bệnh thành công!'),
              backgroundColor: Colors.lightGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if(!mounted) return;
        print('[Edit PMR]Lỗi cập nhật hồ sơ: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật hồ sơ: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Hồ sơ khám bệnh'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Chỉnh sửa hồ sơ cho thú cưng: ${widget.petName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Trường Ngày khám
              ListTile(
                title: Text(
                  'Ngày khám: ${_recordDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

              // Trường Chọn Bác sĩ
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(
                    _selectedVeterinarian == null
                        ? 'Chọn Bác sĩ Thú y'
                        : 'Bác sĩ: ${_selectedVeterinarian!.fullName}',
                    style: TextStyle(
                      color: _selectedVeterinarian == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToVeterinarianSelection,
                ),
              ),
              const SizedBox(height: 20),

              // Các trường nhập liệu
              _buildTextField(_symptomsController, 'Triệu chứng', null, maxLines: 3, isRequired: false),
              _buildTextField(_preliminaryDiagnosisController, 'Chẩn đoán sơ bộ', null, maxLines: 3, isRequired: false),
              _buildTextField(_finalDiagnosisController, 'Chẩn đoán cuối cùng', 'Vui lòng nhập chẩn đoán cuối cùng', maxLines: 3),
              _buildTextField(_treatmentMethodController, 'Phương pháp điều trị', 'Vui lòng nhập phương pháp điều trị', maxLines: 3),
              _buildTextField(_veterinarianNoteController, 'Ghi chú của Bác sĩ (tùy chọn)', null, maxLines: 4, isRequired: false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _updateMedicalRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text(
              'Cập nhật hồ sơ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validationMessage, {int maxLines = 1, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          alignLabelWithHint: true,
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        }
            : null,
      ),
    );
  }
}