import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/canchas/pages/registrar_canchas_page.dart';
import 'package:sport_rent/ui/pages/home_principal/widgets/home_widgets.dart';

class CanchaEmpresaCard extends StatelessWidget {
  final Cancha cancha;
  final VoidCallback onToggleActiva;

  const CanchaEmpresaCard(
      {super.key, required this.cancha, required this.onToggleActiva});

  Color _colorFromDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fÃºtbol':
        return Colors.green;
      case 'tenis':
        return Colors.teal;
      case 'pÃ¡del':
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
