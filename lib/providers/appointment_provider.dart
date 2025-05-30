import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';

class AppointmentProvider extends ChangeNotifier {
  Pet? selectedPet;
  String? selectedVeterinarian;
  DateTime? selectedDateTime;

  void setSelectedPet(Pet pet) {
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
