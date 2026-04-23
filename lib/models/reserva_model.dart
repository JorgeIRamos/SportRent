import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  final String id;
  final String usuarioId;
  final String canchaId;
  final DateTime fecha;
  final String fechaDia;
  final String horaInicio;
  final String horaFin;
  final double montoTotal;
  String estado;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  final String? nombreCliente;
  final String? nombreCancha;

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.canchaId,
    required this.fecha,
    String? fechaDia,
    required this.horaInicio,
    required this.horaFin,
    required this.montoTotal,
    this.estado = 'pendiente',
    DateTime? fechaCreacion,
    DateTime? fechaExpiracion,
    this.nombreCliente,
    this.nombreCancha,
  })  : fechaDia = fechaDia ?? _formatFechaDia(fecha),
        fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaExpiracion =
            fechaExpiracion ?? DateTime.now().add(const Duration(minutes: 30));

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioId': usuarioId,
        'canchaId': canchaId,
        'fecha': fecha.toIso8601String(),
        'fechaDia': fechaDia,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'montoTotal': montoTotal,
        'estado': estado,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaExpiracion': fechaExpiracion.toIso8601String(),
        if (nombreCliente != null) 'nombreCliente': nombreCliente,
        if (nombreCancha != null) 'nombreCancha': nombreCancha,
      };

  static String _formatFechaDia(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        id: json['id'],
        usuarioId: json['usuarioId'],
        canchaId: json['canchaId'],
        fecha: json['fecha'] is Timestamp
            ? (json['fecha'] as Timestamp).toDate()
            : DateTime.parse(json['fecha']),
        fechaDia: json['fechaDia'] ?? _formatFechaDia(json['fecha'] is Timestamp
            ? (json['fecha'] as Timestamp).toDate()
            : DateTime.parse(json['fecha'])),
        horaInicio: json['horaInicio'],
        horaFin: json['horaFin'],
        montoTotal: json['montoTotal']?.toDouble() ?? 0.0,
        estado: json['estado'] ?? 'pendiente',
        fechaCreacion: json['fechaCreacion'] == null
            ? null
            : json['fechaCreacion'] is Timestamp
                ? (json['fechaCreacion'] as Timestamp).toDate()
                : DateTime.tryParse(json['fechaCreacion']),
        fechaExpiracion: json['fechaExpiracion'] == null
            ? null
            : json['fechaExpiracion'] is Timestamp
                ? (json['fechaExpiracion'] as Timestamp).toDate()
                : DateTime.tryParse(json['fechaExpiracion']),
        nombreCliente: json['nombreCliente'],
        nombreCancha: json['nombreCancha'],
      );
}
