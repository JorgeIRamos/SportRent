import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/empresa_model.dart';

class EmpresaController extends GetxController {
  final Rx<Empresa?> empresa = Rx<Empresa?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Estadísticas reactivas
  final RxInt totalCanchas = 0.obs;
  final RxInt canchasActivas = 0.obs;
  final RxInt reservasHoy = 0.obs;
  final RxDouble ingresosMes = 0.0.obs;
  final RxDouble calificacionPromedio = 0.0.obs;

  String get nombreEmpresa => empresa.value?.nombreEmpresa ?? '';
  bool get estaVerificada => empresa.value?.verificada ?? false;

  Future<void> cargarEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 600));

      // Mock: reemplazar con consulta real
      empresa.value = Empresa(
        id: empresaId,
        usuarioId: 'user_emp_001',
        nombreEmpresa: 'Mi Empresa S.A.S',
        nit: '900.123.456-7',
        verificada: true,
      );

      await _cargarEstadisticas(empresaId);
    } catch (e) {
      error.value = 'Error al cargar la empresa';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _cargarEstadisticas(String empresaId) async {
    await Future.delayed(Duration(milliseconds: 300));

    // Mock: reemplazar con datos reales
    totalCanchas.value = 3;
    canchasActivas.value = 2;
    reservasHoy.value = 4;
    ingresosMes.value = 4950000;
    calificacionPromedio.value = 4.6;
  }

  Future<bool> actualizarEmpresa({
    required String nombre,
    required String nit,
  }) async {
    if (nombre.isEmpty || nit.isEmpty) {
      error.value = 'Nombre y NIT son requeridos';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

      if (empresa.value != null) {
        empresa.value = Empresa(
          id: empresa.value!.id,
          usuarioId: empresa.value!.usuarioId,
          nombreEmpresa: nombre,
          nit: nit,
          verificada: empresa.value!.verificada,
          fechaRegistro: empresa.value!.fechaRegistro,
        );
      }

      Get.snackbar('Empresa actualizada', 'Los datos fueron guardados',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al actualizar la empresa';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Datos para el dashboard de estadísticas por período
  Map<String, dynamic> obtenerDatosDashboard(String periodo) {
    switch (periodo) {
      case 'Día':
        return {
          'reservas': [2.0, 3.0, 1.0, 4.0, 2.0, 3.0, 5.0, 2.0, 1.0, 3.0, 4.0, 2.0],
          'ingresos': [900.0, 1350.0, 450.0, 1800.0, 900.0, 1350.0, 2250.0, 900.0, 450.0, 1350.0, 1800.0, 900.0],
          'etiquetas': ['6h', '7h', '8h', '9h', '10h', '11h', '12h', '13h', '14h', '15h', '16h', '17h'],
          'totalReservas': 32,
          'totalIngresos': 14400.0,
          'ocupacion': 68.0,
        };
      case 'Mes':
        return {
          'reservas': [85.0, 92.0, 78.0, 110.0],
          'ingresos': [38250.0, 41400.0, 35100.0, 49500.0],
          'etiquetas': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
          'totalReservas': 365,
          'totalIngresos': 164250.0,
          'ocupacion': 71.0,
        };
      default: // Semana
        return {
          'reservas': [12.0, 18.0, 9.0, 22.0, 15.0, 28.0, 20.0],
          'ingresos': [5400.0, 8100.0, 4050.0, 9900.0, 6750.0, 12600.0, 9000.0],
          'etiquetas': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
          'totalReservas': 124,
          'totalIngresos': 55800.0,
          'ocupacion': 74.0,
        };
    }
  }

  void limpiarError() => error.value = '';
}
