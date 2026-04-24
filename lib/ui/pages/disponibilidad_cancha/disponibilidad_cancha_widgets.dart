import 'package:flutter/material.dart';

class ResumenFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const ResumenFila({
    super.key,
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
