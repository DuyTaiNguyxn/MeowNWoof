import 'package:flutter/material.dart';

class VeterinarianProvider extends ChangeNotifier {
  String? _selectedVeterinarian;

  String? get selectedVeterinarian => _selectedVeterinarian;

  void selectVeterinarian(String vet) {
    _selectedVeterinarian = vet;
    notifyListeners();
  }

  void clearVeterinarian() {
    _selectedVeterinarian = null;
    notifyListeners();
  }
}
