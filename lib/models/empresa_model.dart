class Empresa {
  final String id;
  final String usuarioId;
  final String nombreEmpresa;
  final String nit;
  bool verificada;
  final DateTime fechaRegistro;

  Empresa({
    required this.id,
    required this.usuarioId,
    required this.nombreEmpresa,
    required this.nit,
    this.verificada = false,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'nombreEmpresa': nombreEmpresa,
    'nit': nit,
    'verificada': verificada,
    'fechaRegistro': fechaRegistro.toIso8601String(),
  };

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json['id'],
    usuarioId: json['usuarioId'],
    nombreEmpresa: json['nombreEmpresa'],
    nit: json['nit'],
    verificada: json['verificada'] ?? false,
    fechaRegistro: DateTime.parse(json['fechaRegistro']),
  );
}