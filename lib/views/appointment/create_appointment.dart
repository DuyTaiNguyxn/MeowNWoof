import 'package:flutter/material.dart';
import 'package:meow_n_woof/providers/appointment_provider.dart';
import 'package:meow_n_woof/views/appointment/confirm_create_appointment.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:meow_n_woof/widgets/date_time_picker_widget.dart';
import 'package:provider/provider.dart';

class CreateAppointmentScreen extends StatefulWidget {
  @override
  _CreateAppointmentScreenState createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        appointmentProvider.reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tạo Lịch Khám'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  PetSelectionWidget(
                    selectedPet: appointmentProvider.selectedPet,
                    onPetSelected: (pet) {
                      appointmentProvider.setSelectedPet(pet);
                    },
                  ),
                  VeterinarianSelectionWidget(
                    selectedVet: appointmentProvider.selectedVeterinarian,
                    onVeterinarianSelected: (veterinarian) {
                      appointmentProvider.setSelectedVeterinarian(veterinarian);
                    },
                  ),
                  DateTimePickerWidget(
                    dateTimeSelected: appointmentProvider.selectedDateTime,
                    onDateTimeSelected: (dateTime){
                      appointmentProvider.setSelectedDateTime(dateTime);
                    },
                  ),
                  ConfirmCreateAppointmentScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _prevPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '<',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  Spacer(),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '>',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: () {
                        //Thực hiện lên lịch khám
                        appointmentProvider.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xác nhận tạo lịch khám!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
