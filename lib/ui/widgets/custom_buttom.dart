import 'package:flutter/material.dart';

Widget customButtom(String label, {VoidCallback? onPressed, bool isLoading = false}) {
  return Center(
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent[400],
        foregroundColor: Colors.black87,
        disabledBackgroundColor: Colors.greenAccent[100],
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black54),
            )
          : Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );
}
