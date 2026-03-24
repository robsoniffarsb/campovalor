import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final String hintText;
  final bool isPasswordField;
  final TextEditingController controller;

  const Login({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordField,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 57, 137, 79),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(29),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 57, 137, 79),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(29),
          ),
        ),
      ),
    );
  }
}
