import 'package:flutter/material.dart';

class CreateMedicalRecordScreen extends StatelessWidget {
  final int? petId;
  final String? petName;

  const CreateMedicalRecordScreen({
    super.key,
    this.petId,
    this.petName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Hồ sơ khám bệnh'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Text('Đang tạo hồ sơ cho: ${petName!}'),
      ),
    );
  }
}
