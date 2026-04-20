class Calificacion {
  final String id;
  final String usuarioId;
  final String canchaId;
  final String reservaId;
  final int puntuacion;
  final String comentario;
  final DateTime fecha;

  Calificacion({
    required this.id,
    required this.usuarioId,
    required this.canchaId,
    required this.reservaId,
    required this.puntuacion,
    this.comentario = '',
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'canchaId': canchaId,
    'reservaId': reservaId,
    'puntuacion': puntuacion,
    'comentario': comentario,
    'fecha': fecha.toIso8601String(),
  };

  factory Calificacion.fromJson(Map<String, dynamic> json) => Calificacion(
    id: json['id'],
    usuarioId: json['usuarioId'],
    canchaId: json['canchaId'],
    reservaId: json['reservaId'],
    puntuacion: json['puntuacion'] ?? 1,
    comentario: json['comentario'] ?? '',
    fecha: DateTime.parse(json['fecha']),
  );
}