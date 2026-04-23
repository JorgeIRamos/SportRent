import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/anuncio_model.dart';

class AnuncioService {
  final _db = FirebaseFirestore.instance;
  final _col = 'anuncios';

  Future<String> crearAnuncio(Anuncio anuncio) async {
    final ref = await _db.collection(_col).add(anuncio.toJson());
    return ref.id;
  }

  Future<List<Anuncio>> obtenerPorEmpresa(String empresaId) async {
    final snap = await _db
        .collection(_col)
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snap.docs
        .map((d) => Anuncio.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Anuncio>> obtenerActivos() async {
    final ahora = DateTime.now().toIso8601String();
    final snap = await _db
        .collection(_col)
        .where('activo', isEqualTo: true)
        .where('fechaFin', isGreaterThanOrEqualTo: ahora)
        .orderBy('fechaFin')
        .get();
    return snap.docs
        .map((d) => Anuncio.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<void> actualizarAnuncio(String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> toggleActivo(String id, bool activo) async {
    await _db.collection(_col).doc(id).update({'activo': activo});
  }

  Future<void> eliminarAnuncio(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
