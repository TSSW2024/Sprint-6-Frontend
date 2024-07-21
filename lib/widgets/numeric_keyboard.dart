// lib/widgets/numeric_keyboard.dart
import 'package:flutter/material.dart';

class NumericKeyboard extends StatelessWidget {
  final TextEditingController controller;

  NumericKeyboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildKeyboardRow(['1', '2', '3']),
        _buildKeyboardRow(['4', '5', '6']),
        _buildKeyboardRow(['7', '8', '9']),
        _buildKeyboardRow(['0', '00']),
        _buildKeyboardRow(['Borrar', 'Limpiar']),
      ],
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) {
          return _buildKeyboardButton(key);
        }).toList(),
      ),
    );
  }

  Widget _buildKeyboardButton(String key) {
    return ElevatedButton(
      onPressed: () {
        _onKeyPressed(key);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 8, 8, 8), // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 55.0),
      ),
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _onKeyPressed(String key) {
    if (key == 'Borrar') {
      if (controller.text.isNotEmpty) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
      }
    } else if (key == 'Limpiar') {
      controller.clear();
    } else {
      controller.text += key;
    }
  }
}
