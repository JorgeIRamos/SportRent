import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacion {
  final String id;
  final String usuarioId;
  final String titulo;
  final String mensaje;
  final String tipo; 
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
    'fecha': Timestamp.fromDate(fecha),
  };

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
    id: json['id'],
    usuarioId: json['usuarioId'],
    titulo: json['titulo'],
    mensaje: json['mensaje'],
    tipo: json['tipo'] ?? 'sistema',
    leida: json['leida'] ?? false,
    fecha: () {
      final raw = json['fecha'];
      if (raw == null) return DateTime.now();
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      if (raw is String) {
        final parsed = DateTime.tryParse(raw);
        return parsed ?? DateTime.now();
      }
      return DateTime.now();
    }(),
  );
}