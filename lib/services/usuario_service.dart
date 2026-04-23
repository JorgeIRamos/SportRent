import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/usuario_model.dart';

class UsuarioService {
  final _db = FirebaseFirestore.instance;
  final _col = 'usuarios';

  Future<Usuario?> obtenerUsuario(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Usuario.fromJson({'id': doc.id, ...doc.data()!});
  }

  Future<List<Usuario>> obtenerTodos() async {
    final snap = await _db.collection(_col).get();
    return snap.docs
        .map((d) => Usuario.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> actualizarUsuario(String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> desactivarUsuario(String id) async {
    await _db.collection(_col).doc(id).update({'activo': false});
  }

  Future<void> eliminarUsuario(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
