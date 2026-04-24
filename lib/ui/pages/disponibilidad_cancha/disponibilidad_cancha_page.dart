import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/services/reserva_service.dart';
import 'disponibilidad_cancha_widgets.dart';

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
  int _paginaActual = 0;
  final _pageCtrl = PageController();

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

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = _primerDiaDisponible();
    _cargarHorasOcupadas();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _fechaDia(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

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
                  child: Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 44),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
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
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
            _buildHeaderCancha(cancha, color),
            _buildSeccion(
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
            _buildSeccion(
              titulo: 'Selecciona la hora',
              icono: Icons.schedule_outlined,
              subtitulo: 'Reservas de 1 hora · Toca un horario disponible',
              child: _cargandoSlots
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.green[700]),
                      ),
                    )
                  : _buildGridHoras(),
            ),
            if (_horaSeleccionada != null) ...[_buildResumen(cancha)],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Obx(
                () => ElevatedButton(
                  onPressed: _reservaCtrl.isLoading.value ? null : _confirmarReserva,
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

  Widget _buildImagenCarousel(Cancha cancha, Color color) {
    final fotos = cancha.fotosUrl;
    if (fotos.isEmpty) return _placeholderImagen(color);

    return Stack(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (_, i) => _fotoCancha(fotos[i], color),
          ),
        ),
        if (fotos.length > 1) ...[
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _paginaActual == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _paginaActual == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_paginaActual + 1} / ${fotos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderCancha(Cancha cancha, Color color) {
    return Container(
      color: Colors.green[100],
      child: Column(
        children: [
          _buildImagenCarousel(cancha, color),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cancha.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cancha.tipoDeporte,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.star, size: 14, color: Colors.amber[600]),
                              const SizedBox(width: 3),
                              Text(
                                cancha.calificacionPromedio.toStringAsFixed(1),
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.green[600]),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  cancha.direccion,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatPrecio(cancha.precioPorHora)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'por hora',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoCancha(String url, Color color) {
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(
          bytes,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderImagen(color),
        );
      } catch (_) {
        return _placeholderImagen(color);
      }
    }
    return Image.network(
      url,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholderImagen(color),
    );
  }

  Widget _placeholderImagen(Color color) {
    return Container(
      height: 220,
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          Icons.sports_soccer_outlined,
          size: 80,
          color: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildGridHoras() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slotsDelDia.map((slot) {
        final ocupada = _horasOcupadas.contains(slot);
        final seleccionada = _horaSeleccionada == slot;

        final Color bgColor;
        final Color textColor;
        final Color borderColor;

        if (ocupada) {
          bgColor = Colors.grey[100]!;
          textColor = Colors.grey[400]!;
          borderColor = Colors.grey[200]!;
        } else if (seleccionada) {
          bgColor = Colors.green[700]!;
          textColor = Colors.white;
          borderColor = Colors.green[700]!;
        } else {
          bgColor = Colors.white;
          textColor = Colors.black87;
          borderColor = Colors.green[200]!;
        }

        return GestureDetector(
          onTap: ocupada
              ? null
              : () => setState(
                  () => _horaSeleccionada = seleccionada ? null : slot,
                ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ocupada ? 'Ocupado' : seleccionada ? '✓ Selec.' : 'Libre',
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor,
                    fontWeight:
                        seleccionada ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResumen(Cancha cancha) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                const Text(
                  'Resumen de tu reserva',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResumenFila(
              icono: Icons.sports_soccer_outlined,
              label: 'Cancha',
              valor: cancha.nombre,
            ),
            ResumenFila(
              icono: Icons.calendar_today_outlined,
              label: 'Fecha',
              valor: _formatFecha(_fechaSeleccionada),
            ),
            ResumenFila(
              icono: Icons.schedule_outlined,
              label: 'Horario',
              valor: '$_horaSeleccionada – $_horaFin',
            ),
            const ResumenFila(
              icono: Icons.timer_outlined,
              label: 'Duración',
              valor: '1 hora',
            ),
            Divider(height: 20, color: Colors.grey[200]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${_formatPrecio(cancha.precioPorHora)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required Widget child,
    String? subtitulo,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
