import 'package:flutter/material.dart';

Widget customTimepicker(BuildContext context, String label, String valor, ValueChanged<String> onChange) {
  final controller = TextEditingController(text: valor);

  Future<void> pickTime() async {
    final parts = valor.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formatted;
      onChange(formatted);
    }
  }

  return TextField(
    controller: controller,
    style: TextStyle(fontSize: 13),
    readOnly: true,
    onTap: pickTime,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      suffixIcon: Icon(Icons.access_time, size: 18, color: Colors.green[700]),
    ),
  );
}