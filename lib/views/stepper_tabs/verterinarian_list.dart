import 'package:flutter/material.dart';
import 'date_time_picker.dart';

class SelectDoctorPage extends StatelessWidget {
  final String selectedPet;
  final List<String> doctorList = ['BS. An', 'BS. Bình', 'BS. Cường'];

  SelectDoctorPage({required this.selectedPet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chọn bác sĩ')),
      body: ListView.builder(
        itemCount: doctorList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(doctorList[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectDateTimePage(
                    selectedPet: selectedPet,
                    selectedDoctor: doctorList[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
