import 'package:flutter/material.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/disponibilidad_cancha_widgets.dart';

/// Tarjeta de resumen de reserva: cancha, fecha, horario, duración y total.
class DisponibilidadResumen extends StatelessWidget {
  final Cancha cancha;
  final String fechaFormateada;
  final String horaInicio;
  final String horaFin;
  final String Function(double) formatPrecio;

  const DisponibilidadResumen({
    super.key,
    required this.cancha,
    required this.fechaFormateada,
    required this.horaInicio,
    required this.horaFin,
    required this.formatPrecio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                const Text(
                  'Resumen de tu reserva',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResumenFila(
              icono: Icons.sports_soccer_outlined,
              label: 'Cancha',
              valor: cancha.nombre,
            ),
            ResumenFila(
              icono: Icons.calendar_today_outlined,
              label: 'Fecha',
              valor: fechaFormateada,
            ),
            ResumenFila(
              icono: Icons.schedule_outlined,
              label: 'Horario',
              valor: '$horaInicio – $horaFin',
            ),
            const ResumenFila(
              icono: Icons.timer_outlined,
              label: 'Duración',
              valor: '1 hora',
            ),
            Divider(height: 20, color: Colors.grey[200]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${formatPrecio(cancha.precioPorHora)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección con título, ícono, subtítulo opcional y contenido.
///
/// Extraída aquí porque su único uso es dentro de la pantalla de
/// disponibilidad (fecha y hora).
class DisponibilidadSeccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;
  final String? subtitulo;

  const DisponibilidadSeccion({
    super.key,
    required this.titulo,
    required this.icono,
    required this.child,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitulo!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
