import 'package:flutter/material.dart';

class VaccinationScheduleProvider extends ChangeNotifier {
  String? selectedPet;
  String? diseasePrevented;
  DateTime? selectedDate;

  void setSelectedPet(String pet) {
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
