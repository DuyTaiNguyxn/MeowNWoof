import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/appointment/confirm_create_appointment.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:meow_n_woof/widgets/date_time_picker_widget.dart';

class CreateAppointmentScreen extends StatefulWidget {
  @override
  _CreateAppointmentScreenState createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedPet;
  String? _selectedVeterinarian;
  DateTime? _selectedDateTime;

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
    return Scaffold(
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
                _buildPetSelectionPage(),
                _buildVeterinarianSelectionWidget(),
                _buildDateTimePickerWidget(),
                _buildConfirmationPage(), // sẽ được build lại với dữ liệu mới
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
    );
  }

  Widget _buildPetSelectionPage() => PetSelectionWidget(
    onPetSelected: (selectedPet) {
      setState(() {
        _selectedPet = selectedPet;
      });
    },
  );

  Widget _buildVeterinarianSelectionWidget() => VeterinarianSelectionWidget(
    onVeterinarianSelected: (selectedVeterinarian) {
      setState(() {
        _selectedVeterinarian = selectedVeterinarian;
      });
    },
  );

  Widget _buildDateTimePickerWidget() => DateTimePickerWidget(
    onDateTimeSelected: (dateTime) {
      setState(() {
        _selectedDateTime = dateTime;
      });
    },
  );

  Widget _buildConfirmationPage() => ConfirmCreateAppointmentScreen(
    selectedPet: _selectedPet,
    selectedVeterinarian: _selectedVeterinarian,
    selectedDateTime: _selectedDateTime,
  );
}
