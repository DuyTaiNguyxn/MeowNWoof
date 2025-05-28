import 'package:flutter/material.dart';

class PetProvider extends ChangeNotifier {
  String? _selectedPet;

  String? get selectedPet => _selectedPet;

  void selectPet(String pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void clearPet() {
    _selectedPet = null;
    notifyListeners();
  }
}
