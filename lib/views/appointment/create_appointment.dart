import 'package:flutter/material.dart';
import 'package:meow_n_woof/providers/appointment_provider.dart';
import 'package:meow_n_woof/views/appointment/confirm_create_appointment.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:meow_n_woof/widgets/veterinarian_selection_widget.dart';
import 'package:meow_n_woof/widgets/date_time_picker_widget.dart'; // Đảm bảo đúng đường dẫn và tên file/class
import 'package:provider/provider.dart';

class CreateAppointmentScreen extends StatefulWidget {
  @override
  _CreateAppointmentScreenState createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Biến để lưu trữ ngày giờ cuộc hẹn đã chọn
  DateTime? _appointmentDateTime; // Đây là biến mà bạn sẽ sử dụng để lưu trữ giá trị từ DateTimePickerWidget

  void _nextPage() {
    // Thêm kiểm tra điều kiện trước khi chuyển trang
    // Ví dụ: Không cho phép chuyển trang nếu thông tin của trang hiện tại chưa hợp lệ
    // if (_currentPage == 0 && appointmentProvider.selectedPet == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Vui lòng chọn thú cưng.')),
    //   );
    //   return;
    // }
    // if (_currentPage == 1 && appointmentProvider.selectedVeterinarian == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Vui lòng chọn bác sĩ thú y.')),
    //   );
    //   return;
    // }
    if (_currentPage == 2 && _appointmentDateTime == null) { // Kiểm tra nếu ngày giờ chưa được chọn
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ cuộc hẹn.')),
      );
      return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
          title: const Text('Tạo Lịch Khám'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Không cho phép vuốt để chuyển trang
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
                  // SỬ DỤNG DateTimePickerWidget ĐÃ SỬA ĐỔI
                  DateTimePickerWidget(
                    label: 'Ngày & giờ cuộc hẹn',
                    dateTimeSelected: _appointmentDateTime, // Truyền giá trị hiện tại
                    onDateTimeSelected: (newDateTime) {
                      setState(() {
                        _appointmentDateTime = newDateTime;
                      });
                      // Cập nhật provider nếu bạn muốn lưu vào đó ngay lập tức
                      // appointmentProvider.setAppointmentDateTime(newDateTime);
                      print('Ngày & giờ đã chọn: $newDateTime');
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
                      child: const Text(
                        '<',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  const Spacer(),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage, // Gọi _nextPage() với logic kiểm tra điều kiện
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '>',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: () {
                        // Thực hiện lên lịch khám
                        // Bạn cần truy cập _appointmentDateTime và các giá trị khác từ provider ở đây
                        // Ví dụ:
                        // final selectedPet = appointmentProvider.selectedPet;
                        // final selectedVet = appointmentProvider.selectedVeterinarian;
                        // if (selectedPet != null && selectedVet != null && _appointmentDateTime != null) {
                        //   // GỌI API TẠO LỊCH KHÁM TẠI ĐÂY
                        //   print('Đang tạo lịch khám cho pet: ${selectedPet.petName}, bác sĩ: ${selectedVet.fullName}, vào lúc: $_appointmentDateTime');
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('Đang tạo lịch khám...')),
                        //   );
                        // } else {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('Vui lòng hoàn thành tất cả các thông tin trước khi xác nhận.')),
                        //   );
                        // }

                        appointmentProvider.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xác nhận tạo lịch khám!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
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