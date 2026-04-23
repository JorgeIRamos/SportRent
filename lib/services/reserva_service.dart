import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/reserva_model.dart';

class ReservaService {
  final _db = FirebaseFirestore.instance;
  final _col = 'reservas';

  Future<String> crearReserva(Reserva reserva) async {
    final ref = await _db.collection(_col).add(reserva.toJson());
    return ref.id;
  }

  Future<Reserva?> obtenerReserva(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Reserva.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<List<Reserva>> obtenerPorUsuario(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .get();
    final lista = snap.docs
        .map((d) => Reserva.fromJson({...d.data(), 'id': d.id}))
        .toList();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  Future<List<Reserva>> obtenerPorCancha(String canchaId) async {
    final snap = await _db
        .collection(_col)
        .where('canchaId', isEqualTo: canchaId)
        .get();
    final lista = snap.docs
        .map((d) => Reserva.fromJson({...d.data(), 'id': d.id}))
        .toList();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  Future<List<Reserva>> obtenerPorCanchaYFecha(String canchaId, String fechaDia) async {
    final snap = await _db
        .collection(_col)
        .where('canchaId', isEqualTo: canchaId)
        .where('fechaDia', isEqualTo: fechaDia)
        .where('estado', whereIn: ['pendiente', 'confirmada'])
        .get();
    return snap.docs
        .map((d) => Reserva.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Reserva>> obtenerPorEmpresa(List<String> canchaIds) async {
    if (canchaIds.isEmpty) return [];
    final snap = await _db
        .collection(_col)
        .where('canchaId', whereIn: canchaIds)
        .get();
    final lista = snap.docs
        .map((d) => Reserva.fromJson({...d.data(), 'id': d.id}))
        .toList();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  Future<void> actualizarReserva(String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> eliminarReserva(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
