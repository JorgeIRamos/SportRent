import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/favorito_model.dart';

class FavoritoService {
  final _db = FirebaseFirestore.instance;
  final _col = 'favoritos';

  Future<List<Favorito>> obtenerPorUsuario(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaAgregado', descending: true)
        .get();
    return snap.docs
        .map((d) => Favorito.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Favorito?> obtenerPorUsuarioYCancha(
      String usuarioId, String canchaId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .where('canchaId', isEqualTo: canchaId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return Favorito.fromJson({...d.data(), 'id': d.id});
  }

  Future<String> crearFavorito(Favorito favorito) async {
    final ref = await _db.collection(_col).add(favorito.toJson());
    return ref.id;
  }

  Future<void> eliminarFavorito(String favoritoId) async {
    await _db.collection(_col).doc(favoritoId).delete();
  }
}
