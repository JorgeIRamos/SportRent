import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/models/notificacion_model.dart';
import 'package:sport_rent/ui/pages/home/home_widgets.dart';
import 'package:sport_rent/ui/pages/registrar_canchas/registrar_canchas_page.dart';

class StatCardEmpresa extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const StatCardEmpresa(
      {super.key,
      required this.label,
      required this.valor,
      required this.icono,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 22),
            const SizedBox(height: 4),
            Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class MiniStatEmpresa extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;

  const MiniStatEmpresa(
      {super.key, required this.valor, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class KpiCardEmpresa extends StatelessWidget {
  final String titulo;
  final String valor;
  final String sub;
  final IconData icono;
  final Color color;

  const KpiCardEmpresa(
      {super.key,
      required this.titulo,
      required this.valor,
      required this.sub,
      required this.icono,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valor,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis),
                  Text(titulo, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropChipEmpresa extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool activo;
  final VoidCallback onTap;

  const DropChipEmpresa(
      {super.key,
      required this.label,
      required this.icon,
      required this.activo,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? Colors.green[700]! : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: activo ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: activo ? Colors.white : Colors.grey[800])),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 14, color: activo ? Colors.white : Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

class LeyendaChart extends StatelessWidget {
  final Color color;
  final String texto;

  const LeyendaChart({super.key, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}

class SeccionPerfilEmpresa extends StatelessWidget {
  final String titulo;
  final List<Widget> items;

  const SeccionPerfilEmpresa({super.key, required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(titulo,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ),
            const Divider(height: 1),
            ...items,
          ],
        ),
      ),
    );
  }
}

class InfoItemEmpresa extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const InfoItemEmpresa(
      {super.key, required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icono, size: 20, color: Colors.green[700]),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(valor,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}

class OpcionItemEmpresa extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const OpcionItemEmpresa(
      {super.key, required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: ListTile(
        leading: Icon(icono, color: Colors.green[700], size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

class NotifItemFromModel extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onTap;

  const NotifItemFromModel(
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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

class CanchaEmpresaCard extends StatelessWidget {
  final Cancha cancha;
  final VoidCallback onToggleActiva;

  const CanchaEmpresaCard(
      {super.key, required this.cancha, required this.onToggleActiva});

  Color _colorFromDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
        return Colors.green;
      case 'tenis':
        return Colors.teal;
      case 'pádel':
        return Colors.cyan;
      case 'baloncesto':
        return Colors.orange;
      case 'voleibol':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFromDeporte(cancha.tipoDeporte);
    final bool activa = cancha.activa;
    final String cierreHora =
        cancha.horariosDisponibles.isNotEmpty ? cancha.horariosDisponibles.last : '--';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: cancha.fotosUrl.isNotEmpty
                    ? _fotoCancha(cancha.fotosUrl.first, color, activa)
                    : _placeholderCancha(color, activa),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: activa ? Colors.green[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(activa ? 'Activa' : 'Inactiva',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(cancha.nombre,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_fmt(cancha.precioPorHora.toInt())}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700])),
                        Text('por hora',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(cancha.tipoDeporte,
                          style: TextStyle(
                              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 10),
                    CalificacionEstrellas(rating: cancha.calificacionPromedio, size: 13),
                    const SizedBox(width: 10),
                    Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[600]),
                    const SizedBox(width: 3),
                    Text('Hasta $cierreHora',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrarCancha(cancha: cancha)),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onToggleActiva,
                        icon: Icon(
                            activa
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 16),
                        label: Text(activa ? 'Desactivar' : 'Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              activa ? Colors.red[50] : Colors.green[50],
                          foregroundColor:
                              activa ? Colors.red[700] : Colors.green[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoCancha(String url, Color color, bool activa) {
    final Widget img = url.startsWith('data:')
        ? () {
            try {
              final bytes = base64Decode(url.split(',').last);
              return Image.memory(bytes,
                  height: 130, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholderCancha(color, activa));
            } catch (_) {
              return _placeholderCancha(color, activa);
            }
          }()
        : Image.network(url,
            height: 130, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholderCancha(color, activa));

    return ColorFiltered(
      colorFilter: activa
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: img,
    );
  }

  Widget _placeholderCancha(Color color, bool activa) {
    return Container(
      height: 130,
      width: double.infinity,
      color: activa ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.sports_soccer_outlined,
            size: 60,
            color: activa
                ? color.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  String _fmt(int precio) {
    final s = precio.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
