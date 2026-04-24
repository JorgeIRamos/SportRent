import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/utils/pdf_export_saver.dart';
import 'home_empresa_widgets.dart';

class EstadisticasTab extends StatefulWidget {
  const EstadisticasTab({super.key});

  @override
  State<EstadisticasTab> createState() => _EstadisticasTabState();
}

class _EstadisticasTabState extends State<EstadisticasTab> {
  String _periodo = 'Semana';
  String? _filtroCancha;
  DateTime _fechaRef = DateTime.now();
  final ScreenshotController _screenshotController = ScreenshotController();

  late final ReservaController _reservaCtrl;
  late final CanchaController _canchaCtrl;

  static const _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static const _mesesCortos = [
    'ene.',
    'feb.',
    'mar.',
    'abr.',
    'may.',
    'jun.',
    'jul.',
    'ago.',
    'sep.',
    'oct.',
    'nov.',
    'dic.',
  ];

  List<String> get _canchas =>
      _canchaCtrl.canchas.map((c) => c.nombre).toSet().toList();

  String get _etiquetaPeriodo {
    switch (_periodo) {
      case 'Día':
        return '${_fechaRef.day} ${_mesesCortos[_fechaRef.month - 1]} ${_fechaRef.year}';
      case 'Semana':
        final lunes = DateTime(
          _fechaRef.year,
          _fechaRef.month,
          _fechaRef.day,
        ).subtract(Duration(days: _fechaRef.weekday - 1));
        final domingo = lunes.add(const Duration(days: 6));
        if (lunes.month == domingo.month) {
          return '${lunes.day} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
        }
        if (lunes.year == domingo.year) {
          return '${lunes.day} ${_mesesCortos[lunes.month - 1]} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
        }
        return '${lunes.day} ${_mesesCortos[lunes.month - 1]} ${lunes.year} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
      case 'Año':
        return '${_fechaRef.year}';
      case 'Mes':
      default:
        return '${_meses[_fechaRef.month - 1]} ${_fechaRef.year}';
    }
  }

  void _irAntes() {
    setState(() {
      switch (_periodo) {
        case 'Día':
          _fechaRef = _fechaRef.subtract(const Duration(days: 1));
          break;
        case 'Semana':
          _fechaRef = _fechaRef.subtract(const Duration(days: 7));
          break;
        case 'Año':
          _fechaRef = DateTime(_fechaRef.year - 1, 1, 1);
          break;
        case 'Mes':
          _fechaRef = DateTime(_fechaRef.year, _fechaRef.month - 1, 1);
          break;
      }
    });
  }

  void _irAdelante() {
    setState(() {
      switch (_periodo) {
        case 'Día':
          _fechaRef = _fechaRef.add(const Duration(days: 1));
          break;
        case 'Semana':
          _fechaRef = _fechaRef.add(const Duration(days: 7));
          break;
        case 'Año':
          _fechaRef = DateTime(_fechaRef.year + 1, 1, 1);
          break;
        case 'Mes':
          _fechaRef = DateTime(_fechaRef.year, _fechaRef.month + 1, 1);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _reservaCtrl = Get.find<ReservaController>();
    _canchaCtrl = Get.find<CanchaController>();
  }

  List<Reserva> get _reservasPeriodo {
    DateTime inicio;
    DateTime fin;
    switch (_periodo) {
      case 'Día':
        inicio = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day);
        fin = inicio.add(const Duration(days: 1));
        break;
      case 'Semana':
        inicio = DateTime(
          _fechaRef.year,
          _fechaRef.month,
          _fechaRef.day,
        ).subtract(Duration(days: _fechaRef.weekday - 1));
        fin = inicio.add(const Duration(days: 7));
        break;
      case 'Año':
        inicio = DateTime(_fechaRef.year, 1, 1);
        fin = DateTime(_fechaRef.year + 1, 1, 1);
        break;
      case 'Mes':
      default:
        inicio = DateTime(_fechaRef.year, _fechaRef.month, 1);
        fin = DateTime(_fechaRef.year, _fechaRef.month + 1, 1);
    }
    return _reservaCtrl.reservas.where((r) {
      if (r.fecha.isBefore(inicio) || !r.fecha.isBefore(fin)) return false;
      if (_filtroCancha != null && r.nombreCancha != _filtroCancha)
        return false;
      return true;
    }).toList();
  }

  List<double> get _datosReservas {
    final reservas = _reservasPeriodo;
    switch (_periodo) {
      case 'Día':
        final counts = List.filled(12, 0.0);
        for (final r in reservas) {
          final hora = int.tryParse(r.horaInicio.split(':')[0]) ?? 0;
          final idx = hora - 6;
          if (idx >= 0 && idx < 12) counts[idx]++;
        }
        return counts;
      case 'Semana':
        final inicioSemana = DateTime(
          _fechaRef.year,
          _fechaRef.month,
          _fechaRef.day,
        ).subtract(Duration(days: _fechaRef.weekday - 1));
        final counts = List.filled(7, 0.0);
        for (final r in reservas) {
          final diff = DateTime(
            r.fecha.year,
            r.fecha.month,
            r.fecha.day,
          ).difference(inicioSemana).inDays;
          if (diff >= 0 && diff < 7) counts[diff]++;
        }
        return counts;
      case 'Año':
        final counts = List.filled(12, 0.0);
        for (final r in reservas) {
          counts[r.fecha.month - 1]++;
        }
        return counts;
      case 'Mes':
      default:
        final counts = List.filled(4, 0.0);
        for (final r in reservas) {
          final semana = ((r.fecha.day - 1) ~/ 7).clamp(0, 3);
          counts[semana]++;
        }
        return counts;
    }
  }

  List<double> get _datosIngresos {
    final reservas = _reservasPeriodo
        .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
        .toList();
    switch (_periodo) {
      case 'Día':
        final sums = List.filled(12, 0.0);
        for (final r in reservas) {
          final hora = int.tryParse(r.horaInicio.split(':')[0]) ?? 0;
          final idx = hora - 6;
          if (idx >= 0 && idx < 12) sums[idx] += r.montoTotal;
        }
        return sums;
      case 'Semana':
        final inicioSemana = DateTime(
          _fechaRef.year,
          _fechaRef.month,
          _fechaRef.day,
        ).subtract(Duration(days: _fechaRef.weekday - 1));
        final sums = List.filled(7, 0.0);
        for (final r in reservas) {
          final diff = DateTime(
            r.fecha.year,
            r.fecha.month,
            r.fecha.day,
          ).difference(inicioSemana).inDays;
          if (diff >= 0 && diff < 7) sums[diff] += r.montoTotal;
        }
        return sums;
      case 'Año':
        final sums = List.filled(12, 0.0);
        for (final r in reservas) {
          sums[r.fecha.month - 1] += r.montoTotal;
        }
        return sums;
      case 'Mes':
      default:
        final sums = List.filled(4, 0.0);
        for (final r in reservas) {
          final semana = ((r.fecha.day - 1) ~/ 7).clamp(0, 3);
          sums[semana] += r.montoTotal;
        }
        return sums;
    }
  }

  List<String> get _etiquetas {
    switch (_periodo) {
      case 'Día':
        return [
          '6h',
          '7h',
          '8h',
          '9h',
          '10h',
          '11h',
          '12h',
          '13h',
          '14h',
          '15h',
          '16h',
          '17h',
        ];
      case 'Semana':
        return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      case 'Año':
        return [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic',
        ];
      case 'Mes':
      default:
        return ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
    }
  }

  double get _totalIngresos => _reservasPeriodo
      .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
      .fold(0.0, (a, r) => a + r.montoTotal);

  double get _totalReservas => _reservasPeriodo.length.toDouble();

  double get _ocupacion {
    final total = _reservasPeriodo.length;
    if (total == 0) return 0;
    final activas = _reservasPeriodo
        .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
        .length;
    return activas / total * 100;
  }

  Map<String, int> get _distribucionCanchas {
    final mapa = <String, int>{};
    for (final r in _reservasPeriodo) {
      final nombre = r.nombreCancha ?? 'Sin nombre';
      mapa[nombre] = (mapa[nombre] ?? 0) + 1;
    }
    return mapa;
  }

  List<MapEntry<String, int>> get _horasMasSolicitadas {
    final mapa = <String, int>{};
    for (final r in _reservasPeriodo) {
      final key = '${r.horaInicio} – ${r.horaFin}';
      mapa[key] = (mapa[key] ?? 0) + 1;
    }
    final sorted = mapa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  double get _calificacionPromedio {
    final canchas = _filtroCancha != null
        ? _canchaCtrl.canchas.where((c) => c.nombre == _filtroCancha).toList()
        : _canchaCtrl.canchas.toList();
    final conCalif = canchas.where((c) => c.calificacionPromedio > 0).toList();
    if (conCalif.isEmpty) return 0.0;
    return conCalif.fold(0.0, (sum, c) => sum + c.calificacionPromedio) /
        conCalif.length;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _reservaCtrl.reservas.length;
      _canchaCtrl.canchas.length;
      if (_reservaCtrl.isLoading.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: CircularProgressIndicator(color: Colors.green[700]),
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildDashboardBody(),
      );
    });
  }

  Widget _buildDashboardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFiltros(),
        _buildKpis(),
        _buildSeccion('Reservas por período', _buildBarChart()),
        _buildSeccion('Ingresos (COP)', _buildLineChart()),
        _buildSeccion('Distribución por cancha', _buildPieChart()),
        _buildSeccion('Horas más solicitadas', _buildHorasTable()),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Día', 'Semana', 'Mes', 'Año'].map((p) {
              final sel = _periodo == p;
              return GestureDetector(
                onTap: () => setState(() {
                  _periodo = p;
                  _fechaRef = DateTime.now();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? Colors.green[700] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? Colors.green[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _irAntes,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _etiquetaPeriodo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _irAdelante,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropChipEmpresa(
                  label: _filtroCancha ?? 'Tipo de cancha',
                  icon: Icons.sports_soccer_outlined,
                  activo: _filtroCancha != null,
                  onTap: () => _elegir(
                    _canchas,
                    _filtroCancha,
                    (v) => setState(() => _filtroCancha = v),
                  ),
                ),
                const SizedBox(width: 8),
                if (_filtroCancha != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      _filtroCancha = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Limpiar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _exportarPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Exportar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _elegir(
    List<String> opciones,
    String? actual,
    ValueChanged<String?> onChange,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          if (actual != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: const Text('Mostrar todos'),
              onTap: () {
                onChange(null);
                Navigator.pop(context);
              },
            ),
          ...opciones.map(
            (o) => ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: actual == o ? Colors.green[700] : Colors.grey[400],
              ),
              title: Text(o),
              trailing: actual == o
                  ? Icon(Icons.check, color: Colors.green[700])
                  : null,
              onTap: () {
                onChange(o);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKpis() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              KpiCardEmpresa(
                titulo: 'Ingresos',
                valor: '\$${_fmtK(_totalIngresos)}',
                sub: _periodo,
                icono: Icons.payments_outlined,
                color: Colors.green[700]!,
              ),
              const SizedBox(width: 10),
              KpiCardEmpresa(
                titulo: 'Reservas',
                valor: '${_totalReservas.toInt()}',
                sub: _periodo,
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
                valor: '${_ocupacion.toInt()}%',
                sub: 'Promedio',
                icono: Icons.donut_large_outlined,
                color: Colors.orange[700]!,
              ),
              const SizedBox(width: 10),
              KpiCardEmpresa(
                titulo: 'Calificación',
                valor: _calificacionPromedio == 0
                    ? 'N/D'
                    : '${_calificacionPromedio.toStringAsFixed(1)} ★',
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

  Widget _buildBarChart() {
    final datos = _datosReservas;
    final etiq = _etiquetas;
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
                  if (i < 0 || i >= etiq.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      etiq[i],
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

  Widget _buildLineChart() {
    final datos = _datosIngresos;
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
                  if (i < 0 || i >= _etiquetas.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _etiquetas[i],
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

  Widget _buildPieChart() {
    final distribucion = _distribucionCanchas;
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

  Widget _buildHorasTable() {
    final horas = _horasMasSolicitadas;
    if (horas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Sin reservas en el período seleccionado',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      );
    }
    final maxVal = horas.first.value;
    return Column(
      children: horas
          .map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      h.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxVal > 0 ? h.value / maxVal : 0,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green[600],
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${h.value}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSeccion(String titulo, Widget content) {
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

  String _fmtK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  Future<void> _exportarPdf() async {
    try {
      final now = DateTime.now();
      final bytesDashboard = await _capturarDashboardComoImagen();
      final size = await _decodeImageSize(bytesDashboard);
      final pdf = pw.Document();
      final img = pw.MemoryImage(bytesDashboard);
      final widthPt = size.width * 72 / 96;
      final heightPt = size.height * 72 / 96;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(widthPt + 24, heightPt + 60),
          margin: const pw.EdgeInsets.all(12),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Generado: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.Image(
                img,
                width: widthPt,
                height: heightPt,
                fit: pw.BoxFit.contain,
              ),
            ],
          ),
        ),
      );

      final fileName = _nombreArchivoPeriodo();
      final path = await savePdfBytes(
        bytes: await pdf.save(),
        fileName: fileName,
      );

      Get.snackbar(
        'PDF exportado',
        'Guardado en: $path',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo exportar el PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Uint8List> _capturarDashboardComoImagen() async {
    final media = MediaQuery.of(context);
    final captured = await _screenshotController.captureFromLongWidget(
      Material(
        color: Colors.white,
        child: MediaQuery(
          data: media.copyWith(size: const Size(1200, 2200)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildDashboardBody(),
            ),
          ),
        ),
      ),
      context: context,
      delay: const Duration(milliseconds: 80),
      pixelRatio: 2.0,
    );

    if (captured == null) {
      throw Exception('No fue posible capturar el dashboard');
    }
    return captured;
  }

  Future<Size> _decodeImageSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  String _nombreArchivoPeriodo() {
    String sufijo;
    switch (_periodo) {
      case 'Día':
        sufijo =
            '${_fechaRef.year}${_fechaRef.month.toString().padLeft(2, '0')}${_fechaRef.day.toString().padLeft(2, '0')}';
        break;
      case 'Mes':
        sufijo =
            '${_fechaRef.year}${_fechaRef.month.toString().padLeft(2, '0')}';
        break;
      case 'Año':
        sufijo = '${_fechaRef.year}';
        break;
      case 'Semana':
      default:
        final inicioSemana = DateTime(
          _fechaRef.year,
          _fechaRef.month,
          _fechaRef.day,
        ).subtract(Duration(days: _fechaRef.weekday - 1));
        sufijo =
            '${inicioSemana.year}${inicioSemana.month.toString().padLeft(2, '0')}${inicioSemana.day.toString().padLeft(2, '0')}';
    }
    return 'estadisticas_${_periodo.toLowerCase()}_$sufijo.pdf';
  }
}
