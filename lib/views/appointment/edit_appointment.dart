import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/appointment.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/appointment_service.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  Pet? _selectedPet;
  User? _selectedVeterinarian;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isLoading = false;

  late AppointmentService _appointmentService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.appointment.pet;
    _selectedVeterinarian = widget.appointment.veterinarian;
    _selectedDate = widget.appointment.appointmentDatetime.toLocal();
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.appointmentDatetime.toLocal());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appointmentService = Provider.of<AppointmentService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
    });
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

  Future<void> _submitEditAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thú cưng.')),
        );
        return;
      }
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
        final currentUser = _authService.currentUser;
        if (currentUser == null || currentUser.employeeId == null) {
          throw Exception('Không thể xác định người dùng hiện tại.');
        }

        final DateTime updatedAppointmentDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final updatedAppointment = Appointment(
          id: widget.appointment.id,
          petId: _selectedPet!.petId!,
          veterinarianId: _selectedVeterinarian!.employeeId!,
          appointmentDatetime: updatedAppointmentDateTime,
          status: widget.appointment.status,
          employeeId: currentUser.employeeId!,
        );

        await _appointmentService.updateAppointment(widget.appointment.id!, updatedAppointment);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật lịch hẹn thành công!'),
            backgroundColor: Colors.lightGreen,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('[Edit Appointment] Lỗi cập nhật lịch hẹn: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật lịch hẹn: ${e.toString()}')),
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
        title: const Text('Chỉnh sửa Lịch hẹn khám'),
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

              // Chọn bác sĩ
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
                        : _selectedVeterinarian!.fullName,
                    style: TextStyle(
                      color: _selectedVeterinarian == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToVeterinarianSelection,
                ),
              ),
              const SizedBox(height: 20),

              // Chọn Ngày hẹn
              ListTile(
                title: Text(
                  'Ngày hẹn: ${DateFormat('dd/MM/yyyy').format(_selectedDate.toLocal())}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

              // Chọn Giờ hẹn
              ListTile(
                title: Text(
                  'Giờ hẹn: ${DateFormat('HH:mm').format(DateTime(2023, 1, 1, _selectedTime.hour, _selectedTime.minute))}',
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
            onPressed: () async {
              if (!_hasAppointmentChange()) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không có thông tin nào thay đổi.')),
                );
                return;
              }
              await _submitEditAppointment();
            },
            label: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasAppointmentChange() {
    final originalAppointment = widget.appointment;

    if (_selectedPet?.petId != originalAppointment.petId) {
      return true;
    }
    if (_selectedVeterinarian?.employeeId != originalAppointment.veterinarianId) {
      return true;
    }
    final originalAppointmentDateTime = originalAppointment.appointmentDatetime.toLocal();
    final currentSelectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (currentSelectedDateTime != originalAppointmentDateTime) {
      return true;
    }

    return false;
  }
}