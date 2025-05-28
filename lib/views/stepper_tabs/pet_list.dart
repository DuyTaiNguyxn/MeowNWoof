import 'package:flutter/material.dart';
import 'verterinarian_list.dart';

class SelectPetPage extends StatelessWidget {
  final List<String> petList = ['Milo (Dog)', 'Mimi (Cat)', 'Bim (Bird)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chọn thú cưng')),
      body: ListView.builder(
        itemCount: petList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(petList[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectDoctorPage(selectedPet: petList[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
