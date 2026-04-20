import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/cancha_model.dart';

class CanchaController extends GetxController {
  final RxList<Cancha> canchas = <Cancha>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filtros
  final RxString busqueda = ''.obs;
  final Rx<String?> deporteFiltro = Rx<String?>(null);
  final RxBool soloCercanas = false.obs;
  final RxBool soloFavoritas = false.obs;

  final RxSet<String> _favoritos = <String>{}.obs;

  List<Cancha> get canchasFiltradas {
    return canchas.where((c) {
      if (soloCercanas.value) return false; // sustituir con lógica de distancia real
      if (deporteFiltro.value != null && c.tipoDeporte != deporteFiltro.value) return false;
      if (busqueda.value.isNotEmpty &&
          !c.nombre.toLowerCase().contains(busqueda.value.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  bool esFavorita(String canchaId) => _favoritos.contains(canchaId);

  @override
  void onInit() {
    super.onInit();
    cargarCanchas();
  }

  Future<void> cargarCanchas({String? empresaId}) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 600));

      // Mock: reemplazar con llamada al servicio real
      canchas.assignAll(_canchasMock(empresaId));
    } catch (e) {
      error.value = 'Error al cargar las canchas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registrarCancha(Cancha cancha) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

      canchas.add(cancha);
      Get.snackbar('Éxito', 'Cancha registrada correctamente',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al registrar la cancha';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> actualizarCancha(Cancha cancha) async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 400));

      final index = canchas.indexWhere((c) => c.id == cancha.id);
      if (index != -1) canchas[index] = cancha;

      Get.snackbar('Éxito', 'Cancha actualizada',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al actualizar la cancha';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActiva(String canchaId) async {
    final index = canchas.indexWhere((c) => c.id == canchaId);
    if (index == -1) return;

    final cancha = canchas[index];
    cancha.activa = !cancha.activa;
    canchas[index] = cancha;
    canchas.refresh();
  }

  void toggleFavorita(String canchaId) {
    if (_favoritos.contains(canchaId)) {
      _favoritos.remove(canchaId);
    } else {
      _favoritos.add(canchaId);
    }
  }

  void setBusqueda(String valor) => busqueda.value = valor;
  void setDeporte(String? deporte) => deporteFiltro.value = deporte;
  void toggleCercanas() => soloCercanas.value = !soloCercanas.value;
  void toggleSoloFavoritas() => soloFavoritas.value = !soloFavoritas.value;

  void restablecerFiltros() {
    busqueda.value = '';
    deporteFiltro.value = null;
    soloCercanas.value = false;
    soloFavoritas.value = false;
  }

  List<Cancha> _canchasMock(String? empresaId) => [
        Cancha(
          id: 'c001',
          empresaId: empresaId ?? 'emp_001',
          nombre: 'Cancha Fútbol 5 Premium',
          tipoDeporte: 'Fútbol',
          descripcion: 'Cancha techada con iluminación LED',
          precioPorHora: 450000,
          direccion: 'Calle 15 # 8-32, Valledupar',
          latitud: 10.4631,
          longitud: -73.2532,
          calificacionPromedio: 4.9,
          horariosDisponibles: ['08:00', '09:00', '10:00', '15:00', '16:00', '17:00'],
        ),
        Cancha(
          id: 'c002',
          empresaId: empresaId ?? 'emp_002',
          nombre: 'Cancha de Tenis Central',
          tipoDeporte: 'Tenis',
          descripcion: 'Cancha de tenis en superficie dura',
          precioPorHora: 320000,
          direccion: 'Av. Simón Bolívar # 12-45',
          latitud: 10.4700,
          longitud: -73.2600,
          calificacionPromedio: 4.7,
          horariosDisponibles: ['07:00', '08:00', '09:00', '16:00', '17:00'],
        ),
        Cancha(
          id: 'c003',
          empresaId: empresaId ?? 'emp_003',
          nombre: 'Pádel Arena VIP',
          tipoDeporte: 'Pádel',
          descripcion: 'Canchas de pádel cristal profesional',
          precioPorHora: 280000,
          direccion: 'Cra. 9 # 20-10, Valledupar',
          latitud: 10.4550,
          longitud: -73.2480,
          calificacionPromedio: 4.5,
          horariosDisponibles: ['06:00', '07:00', '18:00', '19:00', '20:00'],
        ),
      ];
}
