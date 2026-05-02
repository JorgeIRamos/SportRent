import 'package:flutter/material.dart';

/// Grilla de slots horarios para la pantalla de disponibilidad.
///
/// Recibe los datos ya computados y devuelve la hora seleccionada (o null para
/// deseleccionar) a través de [onHoraSeleccionada].
class DisponibilidadGridHoras extends StatelessWidget {
  final List<String> slots;
  final Set<String> horasOcupadas;
  final String? horaSeleccionada;
  final ValueChanged<String?> onHoraSeleccionada;

  const DisponibilidadGridHoras({
    super.key,
    required this.slots,
    required this.horasOcupadas,
    required this.horaSeleccionada,
    required this.onHoraSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final ocupada = horasOcupadas.contains(slot);
        final seleccionada = horaSeleccionada == slot;

        final Color bgColor;
        final Color textColor;
        final Color borderColor;

        if (ocupada) {
          bgColor = Colors.grey[100]!;
          textColor = Colors.grey[400]!;
          borderColor = Colors.grey[200]!;
        } else if (seleccionada) {
          bgColor = Colors.green[700]!;
          textColor = Colors.white;
          borderColor = Colors.green[700]!;
        } else {
          bgColor = Colors.white;
          textColor = Colors.black87;
          borderColor = Colors.green[200]!;
        }

        return GestureDetector(
          onTap: ocupada
              ? null
              : () => onHoraSeleccionada(seleccionada ? null : slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ocupada ? 'Ocupado' : seleccionada ? '✓ Selec.' : 'Libre',
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor,
                    fontWeight:
                        seleccionada ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
