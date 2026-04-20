class Estadistica {
  final String empresaId;
  final DateTime periodoInicio;
  final DateTime periodoFin;
  final int totalReservas;
  final double totalIngresos;
  final String horarioMasDemandado;
  final String canchasMasReservada;
  final double tasaOcupacion;
  final Map<String, int> reservasPorDia;
  final Map<String, double> ingresosPorMes;

  Estadistica({
    required this.empresaId,
    required this.periodoInicio,
    required this.periodoFin,
    this.totalReservas = 0,
    this.totalIngresos = 0.0,
    this.horarioMasDemandado = '',
    this.canchasMasReservada = '',
    this.tasaOcupacion = 0.0,
    this.reservasPorDia = const {},
    this.ingresosPorMes = const {},
  });

  Map<String, dynamic> toJson() => {
    'empresaId': empresaId,
    'periodoInicio': periodoInicio.toIso8601String(),
    'periodoFin': periodoFin.toIso8601String(),
    'totalReservas': totalReservas,
    'totalIngresos': totalIngresos,
    'horarioMasDemandado': horarioMasDemandado,
    'canchasMasReservada': canchasMasReservada,
    'tasaOcupacion': tasaOcupacion,
    'reservasPorDia': reservasPorDia,
    'ingresosPorMes': ingresosPorMes,
  };

  factory Estadistica.fromJson(Map<String, dynamic> json) => Estadistica(
    empresaId: json['empresaId'],
    periodoInicio: DateTime.parse(json['periodoInicio']),
    periodoFin: DateTime.parse(json['periodoFin']),
    totalReservas: json['totalReservas'] ?? 0,
    totalIngresos: json['totalIngresos']?.toDouble() ?? 0.0,
    horarioMasDemandado: json['horarioMasDemandado'] ?? '',
    canchasMasReservada: json['canchasMasReservada'] ?? '',
    tasaOcupacion: json['tasaOcupacion']?.toDouble() ?? 0.0,
    reservasPorDia: Map<String, int>.from(json['reservasPorDia'] ?? {}),
    ingresosPorMes: Map<String, double>.from(json['ingresosPorMes'] ?? {}),
  );
}