import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';

class CreateMedicalRecordScreen extends StatelessWidget {
  final Pet selectedPet;

  const CreateMedicalRecordScreen({super.key, required this.selectedPet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Hồ sơ khám bệnh'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Text('Đang tạo hồ sơ cho: ${selectedPet.petName}'),
      ),
    );
  }
}
