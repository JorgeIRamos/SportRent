import 'package:flutter/material.dart';
import 'package:sport_rent/ui/widgets/custom_timepicker.dart';

class HorarioItem extends StatelessWidget {
  final int index;
  final Map<String, String> horario;
  final VoidCallback onEliminar;
  final ValueChanged<Map<String, String>> onCambio;

  const HorarioItem({
    super.key,
    required this.index,
    required this.horario,
    required this.onEliminar,
    required this.onCambio,
  });

  static const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButton<String>(
              value: horario['dia'],
              isExpanded: true,
              underline: const SizedBox(),
              items: _dias
                  .map((d) => DropdownMenuItem(
                      value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (val) => onCambio({...horario, 'dia': val!}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(
                context, 'Inicio', horario['inicio']!, (v) => onCambio({...horario, 'inicio': v})),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(
                context, 'Fin', horario['fin']!, (v) => onCambio({...horario, 'fin': v})),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[300], size: 20),
            onPressed: onEliminar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
