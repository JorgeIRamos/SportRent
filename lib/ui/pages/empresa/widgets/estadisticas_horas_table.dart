import 'package:flutter/material.dart';

class EstadisticasHorasTable extends StatelessWidget {
  final List<MapEntry<String, int>> horas;

  const EstadisticasHorasTable({
    super.key,
    required this.horas,
  });

  @override
  Widget build(BuildContext context) {
    if (horas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Sin reservas en el período seleccionado',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      );
    }
    final maxVal = horas.first.value;
    return Column(
      children: horas
          .map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      h.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxVal > 0 ? h.value / maxVal : 0,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green[600],
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${h.value}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
