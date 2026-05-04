import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/ui/pages/usuario/widgets/home_usuario_widgets.dart';
import 'package:sport_rent/ui/pages/usuario/widgets/reserva_card.dart';

export 'package:sport_rent/ui/pages/usuario/widgets/reserva_card.dart';

class ReservasTabUsuario extends StatelessWidget {
  final ReservaController reservaCtrl;

  const ReservasTabUsuario({super.key, required this.reservaCtrl});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[600]!;
      case 'pendiente':  return Colors.orange[600]!;
      case 'cancelada':  return Colors.red[400]!;
      case 'completada': return Colors.blue[600]!;
      default: return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[50]!;
      case 'pendiente':  return Colors.orange[50]!;
      case 'cancelada':  return Colors.red[50]!;
      case 'completada': return Colors.blue[50]!;
      default: return Colors.grey[100]!;
    }
  }

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Icons.check_circle_outline;
      case 'pendiente':  return Icons.hourglass_empty;
      case 'cancelada':  return Icons.cancel_outlined;
      case 'completada': return Icons.sports_score;
      default: return Icons.info_outline;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'confirmada': return 'Confirmada';
      case 'pendiente':  return 'Pendiente';
      case 'cancelada':  return 'Cancelada';
      case 'completada': return 'Completada';
      default: return estado;
    }
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (dia == hoy) return 'Hoy';
    if (dia == hoy.add(const Duration(days: 1))) return 'Mañana';
    const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${fecha.day} ${meses[fecha.month]}';
  }

  String _fmt(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reservas = reservaCtrl.reservas;
      final filtradas = reservaCtrl.reservasFiltradas;
      final proximas = reservas.where((r) => r.estado == 'confirmada').length;
      final completadas = reservas.where((r) => r.estado == 'pendiente').length;

      return Column(
        children: [
          Container(
            color: Colors.green[100],
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MiniResumenCard(
                      valor: '$proximas',
                      label: 'Confirmadas',
                      color: Colors.green[700]!,
                      icono: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 10),
                    MiniResumenCard(
                      valor: '$completadas',
                      label: 'Pendientes',
                      color: Colors.orange[600]!,
                      icono: Icons.hourglass_empty,
                    ),
                    const SizedBox(width: 10),
                    MiniResumenCard(
                      valor: '${reservas.length}',
                      label: 'Total',
                      color: Colors.grey[700]!,
                      icono: Icons.calendar_month_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Confirmada', 'Pendiente', 'Rechazada', 'Cancelada'].map((f) {
                      final sel = reservaCtrl.filtroEstado.value == f;
                      return GestureDetector(
                        onTap: () => reservaCtrl.setFiltro(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.green[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel ? Colors.green[700]! : Colors.grey[300]!),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? Colors.white : Colors.grey[800])),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filtradas.length} reservas',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14)),
            ),
          ),

          Expanded(
            child: reservaCtrl.isLoading.value
                ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
                : filtradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No hay reservas en esta categoría',
                                style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtradas.length,
                        itemBuilder: (_, i) => ReservaCard(
                          reserva: filtradas[i],
                          reservaCtrl: reservaCtrl,
                          colorEstado: _colorEstado,
                          bgEstado: _bgEstado,
                          iconEstado: _iconEstado,
                          labelEstado: _labelEstado,
                          formatFecha: _formatFecha,
                          fmt: _fmt,
                        ),
                      ),
          ),
        ],
      );
    });
  }
}
