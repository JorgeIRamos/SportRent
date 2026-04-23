import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_rent/models/usuario_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Usuario? _usuarioActual;

  AuthService();

  Usuario? get usuarioActual => _usuarioActual;

  Future<Usuario> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db
        .collection('usuarios')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) throw Exception('Perfil de usuario no encontrado');

    _usuarioActual = Usuario.fromJson({'id': doc.id, ...doc.data()!});
    return _usuarioActual!;
  }

  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    String rol = 'cliente',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final usuario = Usuario(
      id: credential.user!.uid,
      nombre: nombre,
      email: email,
      telefono: telefono,
      rol: rol,
      empresaId: rol == 'empresa' ? credential.user!.uid : null,
    );

    await _db
        .collection('usuarios')
        .doc(usuario.id)
        .set(usuario.toJson());

    _usuarioActual = usuario;
    return usuario;
  }

  Future<void> cambiarPassword({
    required String emailActual,
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión activa');
    final credential = EmailAuthProvider.credential(
      email: emailActual,
      password: passwordActual,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(passwordNuevo);
  }

  Future<void> logout() async {
    await _auth.signOut();
    _usuarioActual = null;
  }

  Future<bool> isSessionActive() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) return false;

    _usuarioActual = Usuario.fromJson({'id': doc.id, ...doc.data()!});
    return true;
  }
}
