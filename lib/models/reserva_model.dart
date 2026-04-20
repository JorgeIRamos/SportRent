class Reserva {
  final String id;
  final String usuarioId;
  final String canchaId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final double montoTotal;
  String estado; // 'pendiente' | 'confirmada' | 'cancelada' | 'expirada'
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.canchaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.montoTotal,
    this.estado = 'pendiente',
    DateTime? fechaCreacion,
    DateTime? fechaExpiracion,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaExpiracion = fechaExpiracion ?? DateTime.now().add(const Duration(minutes: 30));

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'canchaId': canchaId,
    'fecha': fecha.toIso8601String(),
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'montoTotal': montoTotal,
    'estado': estado,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'fechaExpiracion': fechaExpiracion.toIso8601String(),
  };

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
    id: json['id'],
    usuarioId: json['usuarioId'],
    canchaId: json['canchaId'],
    fecha: DateTime.parse(json['fecha']),
    horaInicio: json['horaInicio'],
    horaFin: json['horaFin'],
    montoTotal: json['montoTotal']?.toDouble() ?? 0.0,
    estado: json['estado'] ?? 'pendiente',
    fechaCreacion: DateTime.parse(json['fechaCreacion']),
    fechaExpiracion: DateTime.parse(json['fechaExpiracion']),
  );
}