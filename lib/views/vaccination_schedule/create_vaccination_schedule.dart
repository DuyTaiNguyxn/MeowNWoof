import 'package:flutter/material.dart';
import 'package:meow_n_woof/providers/vaccination_schedule_provider.dart';
import 'package:meow_n_woof/views/vaccination_schedule/confirm_create_vaccination_schedule.dart';
import 'package:meow_n_woof/widgets/date_picker_widget.dart';
import 'package:meow_n_woof/widgets/disease_prevented_widget.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:provider/provider.dart';

class CreateVaccinationScheduleScreen extends StatefulWidget {
  @override
  _CreateVaccinationScheduleScreenState createState() => _CreateVaccinationScheduleScreenState();
}

class _CreateVaccinationScheduleScreenState extends State<CreateVaccinationScheduleScreen> {
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
    final vaccinationProvider = Provider.of<VaccinationScheduleProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        vaccinationProvider.reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tạo Lịch Tiêm phòng'),
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
                    selectedPet: vaccinationProvider.selectedPet,
                    onPetSelected: (pet) {
                      vaccinationProvider.setSelectedPet(pet);
                    },
                  ),
                  DiseasePreventedWidget(
                    diseasePrevented: vaccinationProvider.diseasePrevented,
                    onDiseaseChanged: (disease) => vaccinationProvider.setDiseasePrevented(disease),
                  ),
                  DatePickerWidget(
                    dateSelected: vaccinationProvider.selectedDate,
                    onDateSelected: (dateTime) => vaccinationProvider.setSelectedDateTime(dateTime),
                  ),
                  ConfirmCreateVaccinationScheduleScreen(),
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
                      child: Text('<', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                      child: Text('>', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: () {
                        // Có thể xử lý lưu vào CSDL
                        vaccinationProvider.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xác nhận tạo lịch tiêm chủng!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
