import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/empresa_model.dart';

class EmpresaService {
  final _db = FirebaseFirestore.instance;
  final _col = 'empresas';

  Future<Empresa?> obtenerEmpresa(String empresaId) async {
    final doc = await _db.collection(_col).doc(empresaId).get();
    if (!doc.exists) return null;
    return Empresa.fromJson({'id': doc.id, ...doc.data()!});
  }

  Future<List<Empresa>> obtenerTodas() async {
    final snap = await _db.collection(_col).get();
    return snap.docs
        .map((d) => Empresa.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> crearEmpresa(Empresa empresa) async {
    await _db.collection(_col).doc(empresa.id).set(empresa.toJson());
  }

  Future<void> actualizarEmpresa(String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> eliminarEmpresa(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
