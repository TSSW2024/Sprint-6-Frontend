// lib/widgets/quick_buttons.dart
import 'package:flutter/material.dart';

class QuickButtons extends StatelessWidget {
  final TextEditingController controller;

  QuickButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickButton('5000'),
            _buildQuickButton('10000'),
            _buildQuickButton('20000'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(String amount) {
    return ElevatedButton(
      onPressed: () {
        controller.text = amount;
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 92, 89, 89), // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
      ),
      child: Text('\$$amount'),
    );
  }
}
