import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';

/// Helper de sección que envuelve un widget con título y tarjeta.
class EstadisticasSeccion extends StatelessWidget {
  final String titulo;
  final Widget content;

  const EstadisticasSeccion({
    super.key,
    required this.titulo,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}

/// Gráfico de barras para reservas por período.
class EstadisticasBarChart extends StatelessWidget {
  final List<double> datos;
  final List<String> etiquetas;

  const EstadisticasBarChart({
    super.key,
    required this.datos,
    required this.etiquetas,
  });

  @override
  Widget build(BuildContext context) {
    final maxRaw = datos.isEmpty ? 0.0 : datos.reduce((a, b) => a > b ? a : b);
    final maxY = maxRaw == 0 ? 5.0 : maxRaw * 1.3;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, a) => BarTooltipItem(
                '${rod.toY.toInt()} reservas',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= etiquetas.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      etiquetas[i],
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey[200]!, strokeWidth: 1),
          ),
          barGroups: List.generate(
            datos.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: datos[i],
                  color: Colors.green[600],
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gráfico de línea para ingresos.
class EstadisticasLineChart extends StatelessWidget {
  final List<double> datos;
  final List<String> etiquetas;

  const EstadisticasLineChart({
    super.key,
    required this.datos,
    required this.etiquetas,
  });

  String _fmtK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final maxRaw = datos.isEmpty ? 0.0 : datos.reduce((a, b) => a > b ? a : b);
    final maxY = maxRaw == 0 ? 5000.0 : maxRaw * 1.25;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      '\$${_fmtK(s.y)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= etiquetas.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      etiquetas[i],
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey[200]!, strokeWidth: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                datos.length,
                (i) => FlSpot(i.toDouble(), datos[i]),
              ),
              isCurved: true,
              color: Colors.teal[600],
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (_, a, b, c) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.teal[600]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gráfico de torta para distribución por cancha.
class EstadisticasPieChart extends StatelessWidget {
  final Map<String, int> distribucion;

  const EstadisticasPieChart({
    super.key,
    required this.distribucion,
  });

  @override
  Widget build(BuildContext context) {
    if (distribucion.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Sin datos para el período seleccionado',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      );
    }
    final colores = [
      Colors.green[600]!,
      Colors.lightGreen[500]!,
      Colors.teal[400]!,
      Colors.orange[400]!,
      Colors.blue[400]!,
    ];
    final entradas = distribucion.entries.toList();
    final total = entradas.fold<int>(0, (s, e) => s + e.value);
    final secciones = entradas.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final pct = (e.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: colores[idx % colores.length],
        title: '$pct%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sections: secciones,
              centerSpaceRadius: 36,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entradas
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LeyendaChart(
                      color: colores[entry.key % colores.length],
                      texto: entry.value.key,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
