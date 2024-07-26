import 'package:flutter/material.dart';

class TextFormGlobal extends StatefulWidget {
  const TextFormGlobal({
    super.key,
    required this.controller,
    required this.text,
    required this.textInputType,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;

  @override
  TextFormGlobalState createState() => TextFormGlobalState();
}

class TextFormGlobalState extends State<TextFormGlobal> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(top: 2, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 7,
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.textInputType,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: widget.text,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          hintStyle: const TextStyle(
            height: 1,
          ),
          suffixIcon: widget.obscure
              ? GestureDetector(
                  onTap: _toggleObscureText,
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
