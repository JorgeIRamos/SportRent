import 'package:cloud_firestore/cloud_firestore.dart';

class Favorito {
  final String id;
  final String usuarioId;
  final String canchaId;
  final DateTime fechaAgregado;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.canchaId,
    DateTime? fechaAgregado,
  }) : fechaAgregado = fechaAgregado ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'canchaId': canchaId,
    'fechaAgregado': fechaAgregado.toIso8601String(),
  };

  factory Favorito.fromJson(Map<String, dynamic> json) => Favorito(
    id: json['id'],
    usuarioId: json['usuarioId'],
    canchaId: json['canchaId'],
    fechaAgregado: json['fechaAgregado'] is Timestamp
        ? (json['fechaAgregado'] as Timestamp).toDate()
        : DateTime.parse(json['fechaAgregado']),
  );
}