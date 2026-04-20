class Cancha {
  final String id;
  final String empresaId;
  final String nombre;
  final String tipoDeporte;
  final String descripcion;
  final double precioPorHora;
  final String direccion;
  final double latitud;
  final double longitud;
  final List<String> fotosUrl;
  final List<String> horariosDisponibles;
  double calificacionPromedio;
  bool activa;

  Cancha({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.tipoDeporte,
    required this.precioPorHora,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.descripcion = '',
    this.fotosUrl = const [],
    this.horariosDisponibles = const [],
    this.calificacionPromedio = 0.0,
    this.activa = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresaId': empresaId,
    'nombre': nombre,
    'tipoDeporte': tipoDeporte,
    'descripcion': descripcion,
    'precioPorHora': precioPorHora,
    'direccion': direccion,
    'latitud': latitud,
    'longitud': longitud,
    'fotosUrl': fotosUrl,
    'horariosDisponibles': horariosDisponibles,
    'calificacionPromedio': calificacionPromedio,
    'activa': activa,
  };

  factory Cancha.fromJson(Map<String, dynamic> json) => Cancha(
    id: json['id'],
    empresaId: json['empresaId'],
    nombre: json['nombre'],
    tipoDeporte: json['tipoDeporte'],
    descripcion: json['descripcion'] ?? '',
    precioPorHora: json['precioPorHora']?.toDouble() ?? 0.0,
    direccion: json['direccion'],
    latitud: json['latitud']?.toDouble() ?? 0.0,
    longitud: json['longitud']?.toDouble() ?? 0.0,
    fotosUrl: List<String>.from(json['fotosUrl'] ?? []),
    horariosDisponibles: List<String>.from(json['horariosDisponibles'] ?? []),
    calificacionPromedio: json['calificacionPromedio']?.toDouble() ?? 0.0,
    activa: json['activa'] ?? true,
  );
}