import 'package:flutter/material.dart';
import 'package:sport_rent/models/notificacion_model.dart';

class MiniResumenCard extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;
  final IconData icono;

  const MiniResumenCard(
      {super.key,
      required this.valor,
      required this.label,
      required this.color,
      required this.icono});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 4),
            Text(valor,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class NotifItemUsuario extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onTap;

  const NotifItemUsuario(
      {super.key, required this.notificacion, required this.onTap});

  IconData _icono(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reserva':
        return Icons.calendar_today_outlined;
      case 'calificacion':
        return Icons.star_outline;
      case 'pago':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _color(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reserva':
        return Colors.green;
      case 'calificacion':
        return Colors.amber;
      case 'pago':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(notificacion.tipo);
    final icono = _icono(notificacion.tipo);
    final esNoLeida = !notificacion.leida;

    return Container(
      color: esNoLeida ? Colors.green.withValues(alpha: 0.06) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notificacion.titulo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: esNoLeida ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (esNoLeida)
              const SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                    decoration:
                        BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacion.mensaje,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(_tiempoRelativo(notificacion.fecha),
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
