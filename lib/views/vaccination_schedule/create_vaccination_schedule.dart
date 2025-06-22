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

class CreateVaccinationScreen extends StatefulWidget {
  const CreateVaccinationScreen({super.key});

  @override
  State<CreateVaccinationScreen> createState() => _CreateVaccinationScreenState();
}

class _CreateVaccinationScreenState extends State<CreateVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();

  Pet? _selectedPet;
  Medicine? _selectedVaccine;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _diseasePreventedController = TextEditingController();

  bool _isLoading = false;

  late VaccinationService _vaccinationService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute < 30 ? 0 : 30,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vaccinationService = Provider.of<VaccinationService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _diseasePreventedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _navigateToPetSelection() async {
    final Pet? selectedPet = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetSelectionWidget(
          selectedPet: _selectedPet,
          onPetSelected: (Pet pet) {
            Navigator.pop(context, pet);
          },
        ),
      ),
    );

    if (selectedPet != null) {
      setState(() {
        _selectedPet = selectedPet;
      });
    }
  }

  void _navigateToVaccineSelection() async {
    final Medicine? selectedVaccine = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineSelectionWidget(
          selectedVaccine: _selectedVaccine,
          onVaccineSelected: (Medicine vaccine) {
            Navigator.pop(context, vaccine);
          },
        ),
      ),
    );

    if (selectedVaccine != null) {
      setState(() {
        _selectedVaccine = selectedVaccine;
      });
    }
  }

  Future<void> _submitVaccination() async {
    if (_formKey.currentState!.validate()) {
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
      if (_diseasePreventedController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập thông tin bệnh tiêm phòng.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = _authService.currentUser;
        if (currentUser == null || currentUser.employeeId == null) {
          throw Exception('Không thể xác định người dùng hiện tại.');
        }
        final currentEmployeeId = currentUser.employeeId!;

        final DateTime vaccinationDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final newVaccination = Vaccination(
          petId: _selectedPet!.petId!,
          vaccinationDatetime: vaccinationDateTime,
          diseasePrevented: _diseasePreventedController.text.trim(),
          vaccineId: _selectedVaccine!.medicineId,
          employeeId: currentEmployeeId,
          status: 'confirmed',
        );

        await _vaccinationService.createVaccination(newVaccination);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo lịch tiêm chủng thành công!')),
        );
        Navigator.pop(context, true); // Quay lại và báo thành công
      } catch (e) {
        print('[Create Vaccination] Lỗi tạo lịch tiêm chủng: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo lịch tiêm chủng: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function cho TextFormField
  Widget _buildTextField(TextEditingController controller, String labelText,
      String? Function(String?)? validator,
      {int maxLines = 1, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $labelText';
          }
          return null;
        }
            : validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Lịch tiêm chủng'),
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
              // Chọn thú cưng
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(
                    _selectedPet == null
                        ? 'Chọn Thú cưng'
                        : _selectedPet!.petName,
                    style: TextStyle(
                      color: _selectedPet == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToPetSelection,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                _diseasePreventedController,
                'Bệnh được tiêm phòng',
                    (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên bệnh được tiêm phòng';
                  }
                  return null;
                },
                isRequired: true,
              ),

              // Chọn loại Vaccine
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(
                    _selectedVaccine == null
                        ? 'Chọn Loại Vaccine'
                        : _selectedVaccine!.medicineName, // Hiển thị tên vaccine
                    style: TextStyle(
                      color: _selectedVaccine == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToVaccineSelection,
                ),
              ),
              const SizedBox(height: 20),

              // Chọn Ngày tiêm
              ListTile(
                title: Text(
                  'Ngày tiêm: ${DateFormat('dd/MM/yyyy').format(_selectedDate.toLocal())}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

              // Chọn Giờ tiêm
              ListTile(
                title: Text(
                  'Giờ tiêm: ${DateFormat('HH:mm').format(DateTime(2023, 1, 1, _selectedTime.hour, _selectedTime.minute))}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _submitVaccination,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tạo lịch tiêm',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}