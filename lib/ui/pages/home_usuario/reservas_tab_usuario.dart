import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/calificacion_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'calificacion_sheet.dart';
import 'home_usuario_widgets.dart';

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

class ReservaCard extends StatefulWidget {
  final Reserva reserva;
  final ReservaController reservaCtrl;
  final Color Function(String) colorEstado;
  final Color Function(String) bgEstado;
  final IconData Function(String) iconEstado;
  final String Function(String) labelEstado;
  final String Function(DateTime) formatFecha;
  final String Function(double) fmt;

  const ReservaCard({
    super.key,
    required this.reserva,
    required this.reservaCtrl,
    required this.colorEstado,
    required this.bgEstado,
    required this.iconEstado,
    required this.labelEstado,
    required this.formatFecha,
    required this.fmt,
  });

  @override
  State<ReservaCard> createState() => _ReservaCardState();
}

class _ReservaCardState extends State<ReservaCard> {
  final _calificacionCtrl = Get.find<CalificacionController>();
  final _authCtrl = Get.find<AuthController>();

  bool _yaCalificada = false;
  bool _verificando = true;

  @override
  void initState() {
    super.initState();
    _verificarCalificacion();
  }

  Future<void> _verificarCalificacion() async {
    final estado = widget.reserva.estado;
    if (estado != 'confirmada' && estado != 'completada') {
      if (mounted) setState(() => _verificando = false);
      return;
    }
    final uid = _authCtrl.usuario.value?.id ?? '';
    if (uid.isEmpty) {
      if (mounted) setState(() => _verificando = false);
      return;
    }
    final ya = await _calificacionCtrl.yaCalificada(uid, widget.reserva.id);
    if (mounted) setState(() { _yaCalificada = ya; _verificando = false; });
  }

  void _abrirCalificacion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalificacionSheet(
        reserva: widget.reserva,
        calificacionCtrl: _calificacionCtrl,
        authCtrl: _authCtrl,
        onCalificado: () {
          if (mounted) setState(() => _yaCalificada = true);
        },
      ),
    );
  }

  Widget _botonCalificar() {
    if (_verificando) return const Expanded(child: SizedBox.shrink());
    if (_yaCalificada) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 15, color: Colors.amber[700]),
              const SizedBox(width: 6),
              Text('Ya calificado',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800])),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _abrirCalificacion,
        icon: const Icon(Icons.star_outline, size: 15),
        label: const Text('Calificar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[400],
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.reserva.estado;
    final c = widget.colorEstado(estado);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.sports_outlined, color: c, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reserva.nombreCancha ?? 'Cancha',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Reserva #${widget.reserva.id.substring(0, 6)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: widget.bgEstado(estado),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.iconEstado(estado), size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(widget.labelEstado(estado),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: c)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.formatFecha(widget.reserva.fecha)}  ·  ${widget.reserva.horaInicio} – ${widget.reserva.horaFin}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    Text('\$${widget.fmt(widget.reserva.montoTotal)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700])),
                  ],
                ),
                const SizedBox(height: 10),
                if (estado == 'pendiente') ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            widget.reservaCtrl.cancelarReserva(widget.reserva.id),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final cancha = await Get.find<CanchaController>()
                              .obtenerCanchaPorId(widget.reserva.canchaId);
                          if (cancha != null) {
                            Get.toNamed('/disponibilidad', arguments: cancha);
                          }
                        },
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Ver cancha'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                ],
                if (estado == 'confirmada') ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            widget.reservaCtrl.cancelarReserva(widget.reserva.id),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final cancha = await Get.find<CanchaController>()
                              .obtenerCanchaPorId(widget.reserva.canchaId);
                          if (cancha != null) {
                            Get.toNamed('/disponibilidad', arguments: cancha);
                          }
                        },
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Ver cancha'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [_botonCalificar()]),
                ],
                if (estado == 'completada') ...[
                  Row(children: [
                    _botonCalificar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/home'),
                        icon: const Icon(Icons.replay_outlined, size: 15),
                        label: const Text('Reservar de nuevo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                ],
                if (estado == 'cancelada' || estado == 'rechazada')
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/home'),
                        icon: const Icon(Icons.add_circle_outline, size: 15),
                        label: const Text('Nueva reserva'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
