import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/medical_record.dart';

class CreateMedicalRecordScreen extends StatefulWidget {
  final int petId;
  final String petName;

  const CreateMedicalRecordScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<CreateMedicalRecordScreen> createState() => _CreateMedicalRecordScreenState();
}

class _CreateMedicalRecordScreenState extends State<CreateMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _preliminaryDiagnosisController = TextEditingController();
  final TextEditingController _finalDiagnosisController = TextEditingController();
  final TextEditingController _treatmentMethodController = TextEditingController();
  final TextEditingController _veterinarianNoteController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  User? _selectedVeterinarian;

  bool _isLoading = false;

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

  Future<void> _submitMedicalRecord() async {
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
        final medicalRecordService = Provider.of<MedicalRecordService>(context, listen: false);

        final newRecord = PetMedicalRecord(
          petId: widget.petId,
          recordDate: _recordDate,
          symptoms: _symptomsController.text,
          preliminaryDiagnosis: _preliminaryDiagnosisController.text,
          finalDiagnosis: _finalDiagnosisController.text,
          treatmentMethod: _treatmentMethodController.text,
          veterinarianId: _selectedVeterinarian!.employeeId!,
          veterinarianNote: _veterinarianNoteController.text,
        );

        await medicalRecordService.createMedicalRecord(newRecord);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo hồ sơ khám bệnh thành công!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('[Create PMR]Lỗi tạo hồ sơ: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo hồ sơ: ${e.toString()}')),
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
        title: const Text('Tạo Hồ sơ khám bệnh'),
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
                'Tạo hồ sơ cho thú cưng: ${widget.petName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListTile(
                title: Text(
                  'Ngày khám: ${_recordDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

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
            onPressed: _submitMedicalRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text(
              'Tạo hồ sơ',
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