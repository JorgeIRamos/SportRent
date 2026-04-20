import 'package:flutter/material.dart';

Widget customButtom(String label) {
  return Center(
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent[400],
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );
}