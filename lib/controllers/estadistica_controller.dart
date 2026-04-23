import 'package:get/get.dart';
import 'package:sport_rent/models/estadistica_model.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/services/cancha_service.dart';
import 'package:sport_rent/services/estadistica_service.dart';
import 'package:sport_rent/services/reserva_service.dart';

class EstadisticaController extends GetxController {
  final _estadisticaService = EstadisticaService();
  final _reservaService = ReservaService();
  final _canchaService = CanchaService();

  final Rx<Estadistica?> estadistica = Rx<Estadistica?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> cargarEstadisticas(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      estadistica.value =
          await _estadisticaService.obtenerPorEmpresa(empresaId);
    } catch (e) {
      error.value = 'Error al cargar estadísticas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> calcularYGuardar({
    required String empresaId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final canchas = await _canchaService.obtenerPorEmpresa(empresaId);
      final canchaIds = canchas.map((c) => c.id).take(30).toList();

      if (canchaIds.isEmpty) {
        estadistica.value = Estadistica(
          empresaId: empresaId,
          periodoInicio: inicio,
          periodoFin: fin,
        );
        return;
      }

      final reservas = await _reservaService.obtenerPorEmpresa(canchaIds);
      final reservasPeriodo = reservas
          .where((r) =>
              !r.fecha.isBefore(inicio) && !r.fecha.isAfter(fin))
          .toList();

      final resultado = _calcular(
        empresaId: empresaId,
        inicio: inicio,
        fin: fin,
        reservas: reservasPeriodo,
      );

      await _estadisticaService.guardarEstadisticas(empresaId, resultado);
      estadistica.value = resultado;
    } catch (e) {
      error.value = 'Error al calcular estadísticas';
    } finally {
      isLoading.value = false;
    }
  }

  Estadistica _calcular({
    required String empresaId,
    required DateTime inicio,
    required DateTime fin,
    required List<Reserva> reservas,
  }) {
    final totalReservas = reservas.length;
    final totalIngresos =
        reservas.fold<double>(0.0, (acc, r) => acc + r.montoTotal);

    final reservasPorDia = <String, int>{};
    final ingresosPorMes = <String, double>{};
    final conteoHorario = <String, int>{};
    final conteoCanchas = <String, int>{};

    for (final r in reservas) {
      final dia = r.fecha.toIso8601String().substring(0, 10);
      reservasPorDia[dia] = (reservasPorDia[dia] ?? 0) + 1;

      final mes = r.fecha.toIso8601String().substring(0, 7);
      ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0.0) + r.montoTotal;

      conteoHorario[r.horaInicio] = (conteoHorario[r.horaInicio] ?? 0) + 1;

      conteoCanchas[r.canchaId] = (conteoCanchas[r.canchaId] ?? 0) + 1;
    }

    final horarioMasDemandado = conteoHorario.isEmpty
        ? ''
        : (conteoHorario.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    final cachaMasReservada = conteoCanchas.isEmpty
        ? ''
        : (conteoCanchas.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Estadistica(
      empresaId: empresaId,
      periodoInicio: inicio,
      periodoFin: fin,
      totalReservas: totalReservas,
      totalIngresos: totalIngresos,
      horarioMasDemandado: horarioMasDemandado,
      canchasMasReservada: cachaMasReservada,
      reservasPorDia: reservasPorDia,
      ingresosPorMes: ingresosPorMes,
    );
  }

  void limpiarError() => error.value = '';
}
