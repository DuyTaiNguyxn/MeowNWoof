import 'package:flutter/material.dart';
import 'package:meow_n_woof/widgets/app_bar.dart';

class CreatePetProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Tạo hồ sơ pet'),
      body: Center(child: Text('Trang tạo hồ sơ pet')),
    );
  }
}
