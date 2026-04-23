import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;
  final String? empresaId;
  final DateTime fechaRegistro;
  bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.rol = 'cliente',
    this.empresaId,
    this.activo = true,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'empresaId': empresaId,
        'activo': activo,
        'fechaRegistro': fechaRegistro.toIso8601String(),
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        telefono: json['telefono'] ?? '',
        rol: json['rol'] ?? 'cliente',
        empresaId: json['empresaId'],
        activo: json['activo'] ?? true,
        fechaRegistro: json['fechaRegistro'] is Timestamp
            ? (json['fechaRegistro'] as Timestamp).toDate()
            : DateTime.parse(json['fechaRegistro']),
      );
}
