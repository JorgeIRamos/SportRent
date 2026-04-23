import 'package:get/get.dart';
import 'package:sport_rent/models/favorito_model.dart';
import 'package:sport_rent/services/favorito_service.dart';

class FavoritoController extends GetxController {
  final _favoritoService = FavoritoService();

  final RxList<Favorito> favoritos = <Favorito>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Set<String> get _canchaIds => favoritos.map((f) => f.canchaId).toSet();

  bool esFavorito(String canchaId) => _canchaIds.contains(canchaId);
  int get totalFavoritos => favoritos.length;

  Future<void> cargarFavoritos(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';

      favoritos.assignAll(await _favoritoService.obtenerPorUsuario(usuarioId));
    } catch (e) {
      error.value = 'Error al cargar favoritos';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorito(String usuarioId, String canchaId) async {
    try {
      final existente = await _favoritoService.obtenerPorUsuarioYCancha(
          usuarioId, canchaId);

      if (existente != null) {
        await _favoritoService.eliminarFavorito(existente.id);
        favoritos.removeWhere((f) => f.id == existente.id);
      } else {
        final nuevo = Favorito(id: '', usuarioId: usuarioId, canchaId: canchaId);
        final id = await _favoritoService.crearFavorito(nuevo);
        favoritos.add(Favorito.fromJson({...nuevo.toJson(), 'id': id}));
      }
    } catch (e) {
      error.value = 'Error al actualizar favoritos';
    }
  }

  void limpiarError() => error.value = '';
}
