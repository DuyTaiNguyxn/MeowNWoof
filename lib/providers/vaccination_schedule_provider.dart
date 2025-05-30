import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';

class VaccinationScheduleProvider extends ChangeNotifier {
  Pet? selectedPet;
  String? diseasePrevented;
  DateTime? selectedDate;

  void setSelectedPet(Pet pet) {
    selectedPet = pet;
    notifyListeners();
  }

  void setDiseasePrevented(String disease) {
    diseasePrevented = disease;
    notifyListeners();
  }

  void setSelectedDateTime(DateTime dateTime) {
    selectedDate = dateTime;
    notifyListeners();
  }

  void reset() {
    selectedPet = null;
    diseasePrevented = null;
    selectedDate = null;
    notifyListeners();
  }
}
