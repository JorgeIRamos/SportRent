import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio {
  final String id;
  final String empresaId;
  final String titulo;
  final String descripcion;
  final String? imagenUrl;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  bool activo;
  final DateTime fechaCreacion;

  Anuncio({
    required this.id,
    required this.empresaId,
    required this.titulo,
    required this.descripcion,
    this.imagenUrl,
    required this.fechaInicio,
    required this.fechaFin,
    this.activo = true,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'empresaId': empresaId,
        'titulo': titulo,
        'descripcion': descripcion,
        if (imagenUrl != null) 'imagenUrl': imagenUrl,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'activo': activo,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory Anuncio.fromJson(Map<String, dynamic> json) => Anuncio(
        id: json['id'],
        empresaId: json['empresaId'],
        titulo: json['titulo'],
        descripcion: json['descripcion'] ?? '',
        imagenUrl: json['imagenUrl'],
        fechaInicio: json['fechaInicio'] is Timestamp
            ? (json['fechaInicio'] as Timestamp).toDate()
            : DateTime.parse(json['fechaInicio']),
        fechaFin: json['fechaFin'] is Timestamp
            ? (json['fechaFin'] as Timestamp).toDate()
            : DateTime.parse(json['fechaFin']),
        activo: json['activo'] ?? true,
        fechaCreacion: json['fechaCreacion'] is Timestamp
            ? (json['fechaCreacion'] as Timestamp).toDate()
            : DateTime.parse(json['fechaCreacion']),
      );
}
