import 'package:flutter/material.dart';

class AppointmentProvider extends ChangeNotifier {
  String? selectedPet;
  String? selectedVeterinarian;
  DateTime? selectedDateTime;

  void setSelectedPet(String pet) {
    selectedPet = pet;
    notifyListeners();
  }

  void setSelectedVeterinarian(String veterinarian) {
    selectedVeterinarian = veterinarian;
    notifyListeners();
  }

  void setSelectedDateTime(DateTime dateTime) {
    selectedDateTime = dateTime;
    notifyListeners();
  }

  void reset() {
    selectedPet = null;
    selectedVeterinarian = null;
    selectedDateTime = null;
    notifyListeners();
  }
}
