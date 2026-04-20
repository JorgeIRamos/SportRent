class Empresa {
  final String id;
  final String usuarioId;
  final String nombreEmpresa;
  final String descripcion;
  final String nit;
  final String direccion;
  final String logoUrl;
  bool verificada;
  final DateTime fechaRegistro;

  Empresa({
    required this.id,
    required this.usuarioId,
    required this.nombreEmpresa,
    required this.nit,
    required this.direccion,
    this.descripcion = '',
    this.logoUrl = '',
    this.verificada = false,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'nombreEmpresa': nombreEmpresa,
    'descripcion': descripcion,
    'nit': nit,
    'direccion': direccion,
    'logoUrl': logoUrl,
    'verificada': verificada,
    'fechaRegistro': fechaRegistro.toIso8601String(),
  };

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json['id'],
    usuarioId: json['usuarioId'],
    nombreEmpresa: json['nombreEmpresa'],
    descripcion: json['descripcion'] ?? '',
    nit: json['nit'],
    direccion: json['direccion'],
    logoUrl: json['logoUrl'] ?? '',
    verificada: json['verificada'] ?? false,
    fechaRegistro: DateTime.parse(json['fechaRegistro']),
  );
}