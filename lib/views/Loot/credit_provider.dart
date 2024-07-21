import 'package:flutter/material.dart';

class CreditProvider with ChangeNotifier {
  int _credits = 2000;

  int get credits => _credits;

  void deductCredits(int amount) {
    if (_credits >= amount) {
      _credits -= amount;
      notifyListeners();
    }
  }

  void addCredits(int amount) {
    _credits += amount;
    notifyListeners();
  }
}
