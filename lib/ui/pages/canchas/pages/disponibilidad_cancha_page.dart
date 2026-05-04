import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/services/reserva_service.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/disponibilidad_header.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/disponibilidad_grid_horas.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/disponibilidad_resumen.dart';

class DisponibilidadCancha extends StatefulWidget {
  final Cancha cancha;
  const DisponibilidadCancha({super.key, required this.cancha});

  @override
  State<DisponibilidadCancha> createState() => _DisponibilidadCanchaState();
}

class _DisponibilidadCanchaState extends State<DisponibilidadCancha> {
  final _authCtrl = Get.find<AuthController>();
  final _reservaCtrl = Get.find<ReservaController>();
  final _reservaService = ReservaService();

  late DateTime _fechaSeleccionada;
  String? _horaSeleccionada;
  bool _cargandoSlots = false;
  Set<String> _horasOcupadas = {};

  // ── Slots del día ──────────────────────────────────────────────────────────

  List<String> get _slotsDelDia {
    const nombres = {
      1: 'lunes',
      2: 'martes',
      3: 'miércoles',
      4: 'jueves',
      5: 'viernes',
      6: 'sábado',
      7: 'domingo',
    };
    final diaActual = nombres[_fechaSeleccionada.weekday] ?? '';
    for (final h in widget.cancha.horariosDisponibles) {
      final idx = h.indexOf(' ');
      if (idx == -1) continue;
      if (h.substring(0, idx).toLowerCase() != diaActual) continue;
      final tiempos = h.substring(idx + 1).split('-');
      if (tiempos.length < 2) continue;
      int toMin(String t) {
        final p = t.split(':');
        return int.parse(p[0]) * 60 + int.parse(p[1]);
      }

      String toStr(int m) =>
          '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
      final inicio = toMin(tiempos[0].trim());
      final fin = toMin(tiempos[1].trim());
      return [for (int m = inicio; m < fin; m += 60) toStr(m)];
    }
    return [for (int h = 6; h < 22; h++) '${h.toString().padLeft(2, '0')}:00'];
  }

  String get _horaFin {
    if (_horaSeleccionada == null) return '';
    final slots = _slotsDelDia;
    final idx = slots.indexOf(_horaSeleccionada!);
    if (idx != -1 && idx + 1 < slots.length) {
      return slots[idx + 1];
    }
    final partes = _horaSeleccionada!.split(':');
    if (partes.length != 2) return '';
    final hora = int.tryParse(partes[0]) ?? 0;
    final minutos = int.tryParse(partes[1]) ?? 0;
    final fin =
        Duration(hours: hora, minutes: minutos) + const Duration(hours: 1);
    return '${fin.inHours.toString().padLeft(2, '0')}:${(fin.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  Set<int> get _diasDisponibles {
    const map = {
      'lunes': 1,
      'martes': 2,
      'miércoles': 3,
      'jueves': 4,
      'viernes': 5,
      'sábado': 6,
      'domingo': 7,
    };
    return widget.cancha.horariosDisponibles
        .map((h) => map[h.split(' ').first.toLowerCase()] ?? 0)
        .where((d) => d > 0)
        .toSet();
  }

  DateTime _primerDiaDisponible() {
    final dias = _diasDisponibles;
    if (dias.isEmpty) return DateTime.now().add(const Duration(days: 1));
    var dia = DateTime.now().add(const Duration(days: 1));
    for (int i = 0; i < 7; i++) {
      if (dias.contains(dia.weekday)) return dia;
      dia = dia.add(const Duration(days: 1));
    }
    return dia;
  }

  // ── Ciclo de vida ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = _primerDiaDisponible();
    _cargarHorasOcupadas();
  }

  // ── Helpers de formato ─────────────────────────────────────────────────────

  String _fechaDia(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatFecha(DateTime f) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dias[f.weekday - 1]}, ${f.day} de ${meses[f.month - 1]} de ${f.year}';
  }

  String _formatPrecio(double precio) {
    final s = precio.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Color _colorDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
        return Colors.green;
      case 'tenis':
        return Colors.teal;
      case 'pádel':
        return Colors.cyan;
      case 'baloncesto':
        return Colors.orange;
      case 'voleibol':
        return Colors.blue;
      case 'béisbol':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // ── Lógica de negocio ──────────────────────────────────────────────────────

  Future<void> _cargarHorasOcupadas() async {
    setState(() => _cargandoSlots = true);
    try {
      final f = _fechaSeleccionada;
      final fechaDia = _fechaDia(f);
      final reservas = await _reservaService.obtenerPorCanchaYFecha(
        widget.cancha.id,
        fechaDia,
      );
      if (reservas.isEmpty) {
        final todas = await _reservaService.obtenerPorCancha(widget.cancha.id);
        setState(() {
          _horasOcupadas = todas
              .where(
                (r) =>
                    r.fecha.year == f.year &&
                    r.fecha.month == f.month &&
                    r.fecha.day == f.day &&
                    (r.estado == 'pendiente' || r.estado == 'confirmada'),
              )
              .map((r) => r.horaInicio)
              .toSet();
        });
      } else {
        setState(() {
          _horasOcupadas = reservas.map((r) => r.horaInicio).toSet();
        });
      }
    } catch (_) {
      setState(() {
        _horasOcupadas = {};
      });
    } finally {
      setState(() => _cargandoSlots = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final dias = _diasDisponibles;
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: dias.isEmpty
          ? null
          : (day) => dias.contains(day.weekday),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.green[700]!)),
        child: child!,
      ),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _horaSeleccionada = null;
        _horasOcupadas = {};
      });
      _cargarHorasOcupadas();
    }
  }

  Future<void> _confirmarReserva() async {
    if (!_authCtrl.isLoggedIn) {
      Get.snackbar(
        'Inicia sesión',
        'Necesitas una cuenta para reservar',
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
        icon: Icon(Icons.login, color: Colors.orange[700]),
      );
      Get.toNamed('/login');
      return;
    }
    if (_horaSeleccionada == null) {
      Get.snackbar(
        'Selecciona un horario',
        'Elige una hora disponible para continuar',
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
      );
      return;
    }
    final ok = await _reservaCtrl.crearReserva(
      usuarioId: _authCtrl.usuario.value!.id,
      canchaId: widget.cancha.id,
      fecha: _fechaSeleccionada,
      horaInicio: _horaSeleccionada!,
      horaFin: _horaFin,
      montoTotal: widget.cancha.precioPorHora,
      nombreCliente: _authCtrl.nombre,
      nombreCancha: widget.cancha.nombre,
    );
    if (ok) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.green[600], size: 44),
                ),
                const SizedBox(height: 18),
                const Text(
                  '¡Reserva enviada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tu reserva está pendiente de confirmación. Revisa tus reservas para ver el estado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _reservaCtrl.tabSolicitud.value = 1;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ver mis reservas',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cancha = widget.cancha;
    final color = _colorDeporte(cancha.tipoDeporte);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Disponibilidad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DisponibilidadHeader(
              cancha: cancha,
              color: color,
              formatPrecio: _formatPrecio,
            ),
            DisponibilidadSeccion(
              titulo: 'Selecciona la fecha',
              icono: Icons.calendar_today_outlined,
              child: InkWell(
                onTap: _seleccionarFecha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatFecha(_fechaSeleccionada),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),
            DisponibilidadSeccion(
              titulo: 'Selecciona la hora',
              icono: Icons.schedule_outlined,
              subtitulo: 'Reservas de 1 hora · Toca un horario disponible',
              child: _cargandoSlots
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child:
                            CircularProgressIndicator(color: Colors.green[700]),
                      ),
                    )
                  : DisponibilidadGridHoras(
                      slots: _slotsDelDia,
                      horasOcupadas: _horasOcupadas,
                      horaSeleccionada: _horaSeleccionada,
                      onHoraSeleccionada: (hora) =>
                          setState(() => _horaSeleccionada = hora),
                    ),
            ),
            if (_horaSeleccionada != null)
              DisponibilidadResumen(
                cancha: cancha,
                fechaFormateada: _formatFecha(_fechaSeleccionada),
                horaInicio: _horaSeleccionada!,
                horaFin: _horaFin,
                formatPrecio: _formatPrecio,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      _reservaCtrl.isLoading.value ? null : _confirmarReserva,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _reservaCtrl.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirmar Reserva',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
