import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/vaccination.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:meow_n_woof/widgets/vaccine_selection_widget.dart';
import 'package:provider/provider.dart';

class EditVaccinationScreen extends StatefulWidget {
  final Vaccination vaccination;

  const EditVaccinationScreen({super.key, required this.vaccination});

  @override
  State<EditVaccinationScreen> createState() => _EditVaccinationScreenState();
}

class _EditVaccinationScreenState extends State<EditVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();

  Pet? _selectedPet;
  Medicine? _selectedVaccine;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _diseasePreventedController;

  bool _isLoading = false;

  late VaccinationService _vaccinationService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.vaccination.pet;
    _selectedVaccine = widget.vaccination.vaccine;
    _selectedDate = widget.vaccination.vaccinationDatetime.toLocal();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _diseasePreventedController =
        TextEditingController(text: widget.vaccination.diseasePrevented);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vaccinationService =
          Provider.of<VaccinationService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _diseasePreventedController.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  Future<void> _submitEditVaccination() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng.')),
      );
      return;
    }
    if (_selectedVaccine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vaccine.')),
      );
      return;
    }

    if (!_hasVaccinationChange()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin nào thay đổi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      final employeeId = currentUser?.employeeId;

      if (employeeId == null) {
        throw Exception('Không xác định được nhân viên.');
      }

      final updatedVaccination = Vaccination(
        vaccinationId: widget.vaccination.vaccinationId,
        petId: _selectedPet!.petId!,
        vaccineId: _selectedVaccine!.medicineId,
        diseasePrevented: _diseasePreventedController.text.trim(),
        vaccinationDatetime: _combinedDateTime,
        employeeId: employeeId,
        status: widget.vaccination.status,
      );

      await _vaccinationService.updateVaccination(widget.vaccination.vaccinationId!, updatedVaccination);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật lịch tiêm chủng thành công!'),
          backgroundColor: Colors.lightGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật lịch tiêm chủng: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Lịch tiêm chủng'),
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
              // Pet selection
              _buildSelectTile(
                title: _selectedPet?.petName ?? 'Chọn Thú cưng',
                onTap: () async {
                  final Pet? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PetSelectionWidget(
                        selectedPet: _selectedPet,
                        onPetSelected: (p) => Navigator.pop(context, p),
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() => _selectedPet = result);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Vaccine selection
              _buildSelectTile(
                title: _selectedVaccine?.medicineName ?? 'Chọn Vaccine',
                onTap: () async {
                  final Medicine? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaccineSelectionWidget(
                        selectedVaccine: _selectedVaccine,
                        onVaccineSelected: (v) => Navigator.pop(context, v),
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() => _selectedVaccine = result);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Disease field
              TextFormField(
                controller: _diseasePreventedController,
                decoration: const InputDecoration(
                  labelText: 'Bệnh được tiêm phòng',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Vui lòng nhập tên bệnh'
                    : null,
              ),
              const SizedBox(height: 20),

              // Date picker
              ListTile(
                title: Text(
                  'Ngày tiêm: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              // Time picker
              ListTile(
                title: Text(
                  'Giờ tiêm: ${_selectedTime.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _submitEditVaccination,
            icon: const Icon(Icons.save),
            label: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasVaccinationChange() {
    final originalVaccination = widget.vaccination;

    if (_selectedPet == null ||
        _selectedPet!.petId != originalVaccination.petId) {
      return true;
    }

    if (_selectedVaccine == null ||
        _selectedVaccine!.medicineId != originalVaccination.vaccineId) {
      return true;
    }

    if (_diseasePreventedController.text.trim() != originalVaccination.diseasePrevented) {
      return true;
    }

    final originalVaccinationDateTime = originalVaccination.vaccinationDatetime.toLocal();
    final currentSelectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (currentSelectedDateTime != originalVaccinationDateTime) {
      return true;
    }

    return false;
  }

  Widget _buildSelectTile({required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: title.startsWith('Chọn') ? Colors.grey[600] : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
