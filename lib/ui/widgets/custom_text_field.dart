import 'package:flutter/material.dart';

Widget customField(String label, IconData icon, {bool obscure = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
    child: TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    ),
  );
}