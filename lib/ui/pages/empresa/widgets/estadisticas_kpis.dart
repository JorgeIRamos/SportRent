import 'package:flutter/material.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';

class EstadisticasKpis extends StatelessWidget {
  final double totalIngresos;
  final double totalReservas;
  final double ocupacion;
  final double calificacionPromedio;
  final String periodo;

  const EstadisticasKpis({
    super.key,
    required this.totalIngresos,
    required this.totalReservas,
    required this.ocupacion,
    required this.calificacionPromedio,
    required this.periodo,
  });

  String _fmtK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              KpiCardEmpresa(
                titulo: 'Ingresos',
                valor: '\$${_fmtK(totalIngresos)}',
                sub: periodo,
                icono: Icons.payments_outlined,
                color: Colors.green[700]!,
              ),
              const SizedBox(width: 10),
              KpiCardEmpresa(
                titulo: 'Reservas',
                valor: '${totalReservas.toInt()}',
                sub: periodo,
                icono: Icons.calendar_today_outlined,
                color: Colors.teal[600]!,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              KpiCardEmpresa(
                titulo: 'Ocupación',
                valor: '${ocupacion.toInt()}%',
                sub: 'Promedio',
                icono: Icons.donut_large_outlined,
                color: Colors.orange[700]!,
              ),
              const SizedBox(width: 10),
              KpiCardEmpresa(
                titulo: 'Calificación',
                valor: calificacionPromedio == 0
                    ? 'N/D'
                    : '${calificacionPromedio.toStringAsFixed(1)} ☆',
                sub: 'Promedio',
                icono: Icons.star_outline,
                color: Colors.amber[700]!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
