class Notificacion {
  final String id;
  final String usuarioId;
  final String titulo;
  final String mensaje;
  final String tipo; // 'reserva' | 'pago' | 'cancelacion' | 'sistema'
  bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    this.tipo = 'sistema',
    this.leida = false,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'titulo': titulo,
    'mensaje': mensaje,
    'tipo': tipo,
    'leida': leida,
    'fecha': fecha.toIso8601String(),
  };

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
    id: json['id'],
    usuarioId: json['usuarioId'],
    titulo: json['titulo'],
    mensaje: json['mensaje'],
    tipo: json['tipo'] ?? 'sistema',
    leida: json['leida'] ?? false,
    fecha: DateTime.parse(json['fecha']),
  );
}