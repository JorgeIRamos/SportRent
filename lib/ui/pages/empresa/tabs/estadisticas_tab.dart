import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/utils/pdf_export_saver.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/estadisticas_filtros.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/estadisticas_kpis.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/estadisticas_charts.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/estadisticas_horas_table.dart';

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

  // ── Getters de cómputo ───────────────────────────────────────────────────

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
      if (_filtroCancha != null && r.nombreCancha != _filtroCancha) return false;
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
          '6h', '7h', '8h', '9h', '10h', '11h',
          '12h', '13h', '14h', '15h', '16h', '17h',
        ];
      case 'Semana':
        return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      case 'Año':
        return [
          'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
          'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
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

  // ── Build principal ──────────────────────────────────────────────────────

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
        EstadisticasFiltros(
          periodo: _periodo,
          etiquetaPeriodo: _etiquetaPeriodo,
          filtroCancha: _filtroCancha,
          canchas: _canchas,
          onAntes: _irAntes,
          onAdelante: _irAdelante,
          onPeriodoChanged: (p) => setState(() {
            _periodo = p;
            _fechaRef = DateTime.now();
          }),
          onFiltroCanchaChanged: (v) => setState(() => _filtroCancha = v),
          onExportarPdf: _exportarPdf,
        ),
        EstadisticasKpis(
          totalIngresos: _totalIngresos,
          totalReservas: _totalReservas,
          ocupacion: _ocupacion,
          calificacionPromedio: _calificacionPromedio,
          periodo: _periodo,
        ),
        EstadisticasSeccion(
          titulo: 'Reservas por período',
          content: EstadisticasBarChart(
            datos: _datosReservas,
            etiquetas: _etiquetas,
          ),
        ),
        EstadisticasSeccion(
          titulo: 'Ingresos (COP)',
          content: EstadisticasLineChart(
            datos: _datosIngresos,
            etiquetas: _etiquetas,
          ),
        ),
        EstadisticasSeccion(
          titulo: 'Distribución por cancha',
          content: EstadisticasPieChart(
            distribucion: _distribucionCanchas,
          ),
        ),
        EstadisticasSeccion(
          titulo: 'Horas más solicitadas',
          content: EstadisticasHorasTable(
            horas: _horasMasSolicitadas,
          ),
        ),
      ],
    );
  }

  // ── Exportar PDF ─────────────────────────────────────────────────────────

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
