import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/estadistica_model.dart';

class EstadisticaService {
  final _db = FirebaseFirestore.instance;
  final _col = 'estadisticas';

  Future<Estadistica?> obtenerPorEmpresa(String empresaId) async {
    final snap = await _db
        .collection(_col)
        .where('empresaId', isEqualTo: empresaId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return Estadistica.fromJson({...d.data(), 'id': d.id});
  }

  Future<void> guardarEstadisticas(
      String empresaId, Estadistica estadistica) async {
    final snap = await _db
        .collection(_col)
        .where('empresaId', isEqualTo: empresaId)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update(estadistica.toJson());
    } else {
      await _db.collection(_col).add(estadistica.toJson());
    }
  }
}
