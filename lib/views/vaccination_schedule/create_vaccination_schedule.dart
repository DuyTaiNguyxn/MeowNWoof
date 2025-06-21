// import 'package:flutter/material.dart';
// import 'package:meow_n_woof/providers/vaccination_schedule_provider.dart';
// import 'package:meow_n_woof/views/vaccination_schedule/confirm_create_vaccination_schedule.dart';
// import 'package:meow_n_woof/widgets/date_time_picker_widget.dart'; // Đảm bảo đã import widget đúng
// import 'package:meow_n_woof/widgets/disease_prevented_widget.dart';
// import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
// import 'package:provider/provider.dart';
//
// class CreateVaccinationScheduleScreen extends StatefulWidget {
//   const CreateVaccinationScheduleScreen({super.key});
//
//   @override
//   _CreateVaccinationScheduleScreenState createState() => _CreateVaccinationScheduleScreenState();
// }
//
// class _CreateVaccinationScheduleScreenState extends State<CreateVaccinationScheduleScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//
//   void _nextPage() {
//     // Thêm logic kiểm tra điều kiện trước khi chuyển trang
//     final vaccinationProvider = Provider.of<VaccinationScheduleProvider>(context, listen: false);
//
//     if (_currentPage == 0 && vaccinationProvider.selectedPet == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn thú cưng.')),
//       );
//       return;
//     }
//     if (_currentPage == 1 && vaccinationProvider.diseasePrevented == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn bệnh cần phòng ngừa.')),
//       );
//       return;
//     }
//     if (_currentPage == 2 && vaccinationProvider.selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn ngày và giờ tiêm phòng.')),
//       );
//       return;
//     }
//
//     if (_currentPage < 3) {
//       _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//   }
//
//   void _prevPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vaccinationProvider = Provider.of<VaccinationScheduleProvider>(context);
//     return WillPopScope(
//       onWillPop: () async {
//         vaccinationProvider.reset();
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Tạo Lịch Tiêm phòng'),
//           backgroundColor: Colors.lightBlueAccent,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(), // Không cho phép vuốt để chuyển trang
//                 onPageChanged: (index) => setState(() => _currentPage = index),
//                 children: [
//                   PetSelectionWidget(
//                     selectedPet: vaccinationProvider.selectedPet,
//                     onPetSelected: (pet) {
//                       vaccinationProvider.setSelectedPet(pet);
//                     },
//                   ),
//                   DiseasePreventedWidget(
//                     diseasePrevented: vaccinationProvider.diseasePrevented,
//                     onDiseaseChanged: (disease) => vaccinationProvider.setDiseasePrevented(disease),
//                   ),
//                   // SỬA Ở ĐÂY: Thêm thuộc tính `label`
//                   DateTimePickerWidget(
//                     label: 'Ngày & giờ tiêm phòng', // <-- Thêm label ở đây
//                     dateTimeSelected: vaccinationProvider.selectedDate,
//                     onDateTimeSelected: (dateTime){
//                       vaccinationProvider.setSelectedDateTime(dateTime!);
//                     },
//                   ),
//                   ConfirmCreateVaccinationScheduleScreen(),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   if (_currentPage > 0)
//                     ElevatedButton(
//                       onPressed: _prevPage,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.lightBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('<', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                     ),
//                   const Spacer(),
//                   if (_currentPage < 3)
//                     ElevatedButton(
//                       onPressed: _nextPage, // Gọi _nextPage() với logic kiểm tra điều kiện
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.lightBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('>', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                     ),
//                   if (_currentPage == 3)
//                     ElevatedButton(
//                       onPressed: () {
//                         // Logic lưu lịch tiêm chủng vào CSDL
//                         // Truy cập các giá trị từ provider:
//                         // final selectedPet = vaccinationProvider.selectedPet;
//                         // final diseasePrevented = vaccinationProvider.diseasePrevented;
//                         // final selectedDate = vaccinationProvider.selectedDate;
//
//                         // TODO: Gọi API hoặc lưu vào CSDL ở đây
//
//                         vaccinationProvider.reset(); // Reset provider sau khi tạo thành công
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Đã xác nhận tạo lịch tiêm chủng!')),
//                         );
//                         // Có thể thêm Navigator.pop(context) để quay về màn hình trước
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.lightBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }