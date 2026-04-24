import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/services/cancha_service.dart';

class CanchaController extends GetxController {
  final _canchaService = CanchaService();

  final RxList<Cancha> canchas = <Cancha>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxString busqueda = ''.obs;
  final Rx<String?> deporteFiltro = Rx<String?>(null);
  final RxBool soloCercanas = false.obs;
  final Rx<Position?> posicionUsuario = Rx<Position?>(null);
  final RxBool cargandoUbicacion = false.obs;

  List<Cancha> get canchasFiltradas {
    var lista = canchas.where((c) {
      if (!c.activa) return false;
      if (deporteFiltro.value != null && c.tipoDeporte != deporteFiltro.value) return false;
      if (busqueda.value.isNotEmpty &&
          !c.nombre.toLowerCase().contains(busqueda.value.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    if (soloCercanas.value && posicionUsuario.value != null) {
      lista.sort((a, b) => _distanciaKmA(a).compareTo(_distanciaKmA(b)));
    }

    return lista;
  }

  double _distanciaKmA(Cancha c) {
    final pos = posicionUsuario.value;
    if (pos == null || (c.latitud == 0 && c.longitud == 0)) return double.infinity;
    return Geolocator.distanceBetween(
          pos.latitude, pos.longitude, c.latitud, c.longitud) /
        1000;
  }

  double? distanciaKm(Cancha c) {
    final pos = posicionUsuario.value;
    if (pos == null || (c.latitud == 0 && c.longitud == 0)) return null;
    return Geolocator.distanceBetween(
          pos.latitude, pos.longitude, c.latitud, c.longitud) /
        1000;
  }

  @override
  void onInit() {
    super.onInit();
    _obtenerPosicionSilenciosa();
  }

  Future<void> _obtenerPosicionSilenciosa() async {
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return;
      }
      posicionUsuario.value = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {}
  }

  Future<void> cargarCanchas({String? empresaId}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final resultado = (empresaId != null && empresaId.isNotEmpty)
          ? await _canchaService.obtenerPorEmpresa(empresaId)
          : await _canchaService.obtenerActivas();

      canchas.assignAll(resultado);
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

      final id = await _canchaService.crearCancha(cancha);
      canchas.add(Cancha.fromJson({...cancha.toJson(), 'id': id}));

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
      error.value = '';

      await _canchaService.actualizarCancha(cancha.id, cancha.toJson());

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

    final nuevoEstado = !canchas[index].activa;

    try {
      await _canchaService.toggleActiva(canchaId, nuevoEstado);
      canchas[index].activa = nuevoEstado;
      canchas.refresh();
    } catch (e) {
      error.value = 'Error al cambiar estado de la cancha';
    }
  }

  void setBusqueda(String valor) => busqueda.value = valor;
  void setDeporte(String? deporte) => deporteFiltro.value = deporte;

  Future<void> toggleCercanas() async {
    if (!soloCercanas.value && posicionUsuario.value == null) {
      await _obtenerPosicion();
      if (posicionUsuario.value == null) return;
    }
    soloCercanas.value = !soloCercanas.value;
  }

  Future<void> _obtenerPosicion() async {
    try {
      cargandoUbicacion.value = true;
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permiso denegado',
          'Activa la ubicación para usar este filtro',
          backgroundColor: Colors.orange[100],
          colorText: Colors.black87,
        );
        return;
      }
      posicionUsuario.value = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo obtener la ubicación',
        backgroundColor: Colors.red[100],
        colorText: Colors.black87,
      );
    } finally {
      cargandoUbicacion.value = false;
    }
  }

  void restablecerFiltros() {
    busqueda.value = '';
    deporteFiltro.value = null;
    soloCercanas.value = false;
  }

  Future<Cancha?> obtenerCanchaPorId(String canchaId) async {
    try {
      return canchas.firstWhere((c) => c.id == canchaId);
    } catch (_) {
      return await _canchaService.obtenerCancha(canchaId);
    }
  }

  void actualizarCalificacionLocal(String canchaId, double promedio) {
    final index = canchas.indexWhere((c) => c.id == canchaId);
    if (index != -1) {
      canchas[index].calificacionPromedio = promedio;
      canchas.refresh();
    }
  }

  void limpiarError() => error.value = '';
}
