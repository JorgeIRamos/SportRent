import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'home_empresa_widgets.dart';

class ReservasTabEmpresa extends StatefulWidget {
  const ReservasTabEmpresa({super.key});

  @override
  State<ReservasTabEmpresa> createState() => _ReservasTabEmpresaState();
}

class _ReservasTabEmpresaState extends State<ReservasTabEmpresa> {
  final _ctrl = Get.find<ReservaController>();

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[600]!;
      case 'pendiente':  return Colors.orange[600]!;
      case 'cancelada':  return Colors.red[400]!;
      case 'rechazada':  return Colors.red[700]!;
      case 'completada': return Colors.blue[600]!;
      default: return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[50]!;
      case 'pendiente':  return Colors.orange[50]!;
      case 'cancelada':  return Colors.red[50]!;
      case 'rechazada':  return Colors.red[50]!;
      case 'completada': return Colors.blue[50]!;
      default: return Colors.grey[100]!;
    }
  }

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatFecha(DateTime fecha) {
    final hoy = DateTime.now();
    if (fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day) {
      return 'Hoy';
    }
    final man = hoy.add(const Duration(days: 1));
    if (fecha.year == man.year && fecha.month == man.month && fecha.day == man.day) {
      return 'Mañana';
    }
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  String _fmt(int v) {
    final s = v.toString();
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
      final lista = _ctrl.reservasFiltradas;
      final filtro = _ctrl.filtroEstado.value;
      final empresaVerificada = Get.find<EmpresaController>().estaVerificada;
      return Column(
        children: [
          Container(
            color: Colors.green[100],
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    MiniStatEmpresa(valor: '${_ctrl.totalConfirmadas}', label: 'Confirm.', color: Colors.green[600]!),
                    const SizedBox(width: 8),
                    MiniStatEmpresa(valor: '${_ctrl.totalPendientes}', label: 'Pendientes', color: Colors.orange[600]!),
                    const SizedBox(width: 8),
                    MiniStatEmpresa(valor: '${_ctrl.totalCanceladas}', label: 'Canceladas', color: Colors.red[400]!),
                    const SizedBox(width: 8),
                    MiniStatEmpresa(valor: '${_ctrl.reservas.length}', label: 'Total', color: Colors.green[800]!),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Confirmada', 'Pendiente', 'Cancelada', 'Rechazada'].map((f) {
                      final sel = filtro == f;
                      return GestureDetector(
                        onTap: () => _ctrl.setFiltro(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.green[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? Colors.green[700]! : Colors.grey[300]!),
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
              child: Text('${lista.length} reservas',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          ),
          if (_ctrl.isLoading.value)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.green)))
          else
            Expanded(
              child: lista.isEmpty
                  ? Center(child: Text('No hay reservas', style: TextStyle(color: Colors.grey[500])))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: lista.length,
                      itemBuilder: (_, i) {
                        final Reserva r = lista[i];
                        final String estado = r.estado;
                        return Container(
                          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Icon(Icons.sports_soccer_outlined, color: Colors.green[700]),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Reserva #${r.id.substring(0, 6)}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                          const SizedBox(height: 6),
                                          Text(r.nombreCliente ?? 'Cliente desconocido',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          const SizedBox(height: 4),
                                          Text('Cancha: ${r.nombreCancha ?? r.canchaId}',
                                              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: _bgEstado(estado),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Text(_capitalizar(estado),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _colorEstado(estado),
                                          )),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('${_formatFecha(r.fecha)} · ${r.horaInicio} – ${r.horaFin}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text('Total: \$${_fmt(r.montoTotal.toInt())}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                if (!empresaVerificada) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Empresa pendiente de aprobación. No puedes gestionar reservas.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ] else if (estado == 'pendiente') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _ctrl.rechazarReserva(r.id),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red[700],
                                            side: BorderSide(color: Colors.red[200]!),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text('Rechazar reserva'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _ctrl.confirmarReserva(r.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text('Aceptar reserva'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (estado == 'confirmada') ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => _ctrl.cancelarReserva(r.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red[700],
                                      side: BorderSide(color: Colors.red[200]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Cancelar reserva'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      );
    });
  }
}
