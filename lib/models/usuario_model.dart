class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String fotoUrl;
  final String rol; // 'cliente' | 'empresa' | 'admin'
  final DateTime fechaRegistro;
  bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.fotoUrl = '',
    this.rol = 'cliente',
    this.activo = true,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'fotoUrl': fotoUrl,
    'rol': rol,
    'activo': activo,
    'fechaRegistro': fechaRegistro.toIso8601String(),
  };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'],
    nombre: json['nombre'],
    email: json['email'],
    telefono: json['telefono'] ?? '',
    fotoUrl: json['fotoUrl'] ?? '',
    rol: json['rol'] ?? 'cliente',
    activo: json['activo'] ?? true,
    fechaRegistro: DateTime.parse(json['fechaRegistro']),
  );
}
