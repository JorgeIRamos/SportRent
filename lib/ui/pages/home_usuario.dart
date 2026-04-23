import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/calificacion_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/favorito_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/models/notificacion_model.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/ui/pages/home.dart';

class HomeUsuario extends StatefulWidget {
  final String nombreUsuario;

  const HomeUsuario({super.key, required this.nombreUsuario});

  @override
  State<HomeUsuario> createState() => _HomeUsuarioState();
}

class _HomeUsuarioState extends State<HomeUsuario> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _favoritoCtrl = Get.find<FavoritoController>();
  final _reservaCtrl = Get.find<ReservaController>();
  final _authCtrl = Get.find<AuthController>();
  final _notificacionCtrl = Get.find<NotificacionController>();
  final _buscarCtrl = TextEditingController();

  bool _soloFavoritos = false;
  int _navIndex = 0;
  Worker? _uidWorker;

  static const _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  @override
  void initState() {
    super.initState();
    _canchaCtrl.cargarCanchas();
    final uid = _authCtrl.usuario.value?.id ?? '';
    if (uid.isNotEmpty) {
      _cargarDatosUsuario(uid);
    } else {
      _uidWorker = once(_authCtrl.usuario, (u) {
        if (u != null) _cargarDatosUsuario(u.id);
      });
    }
  }

  void _cargarDatosUsuario(String uid) {
    _favoritoCtrl.cargarFavoritos(uid);
    _reservaCtrl.cargarReservasUsuario(uid);
    _notificacionCtrl.cargarNotificaciones(uid);
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    _uidWorker?.dispose();
    super.dispose();
  }

  List<Cancha> get _listaFinal {
    final base = _canchaCtrl.canchasFiltradas;
    if (_soloFavoritos) {
      return base.where((c) => _favoritoCtrl.esFavorito(c.id)).toList();
    }
    return base;
  }

  void _restablecerFiltros() {
    setState(() {
      _soloFavoritos = false;
      _buscarCtrl.clear();
    });
    _canchaCtrl.restablecerFiltros();
  }

  String get _appBarTitle {
    switch (_navIndex) {
      case 1:
        return 'Mis Reservas';
      case 2:
        return 'Mi Perfil';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
        title: _navIndex == 0
            ? Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.green[700], size: 20),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu Ubicación',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal)),
                      Text('SportRent',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ],
              )
            : Text(_appBarTitle,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () => _mostrarNotificaciones(context),
              ),
              Obx(() {
                final n = _notificacionCtrl.totalNoLeidas;
                if (n <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$n',
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // ── NOTIFICACIONES ──────────────────────────────────────────────────────────

  void _mostrarNotificaciones(BuildContext context) {
    _notificacionCtrl.marcarTodasLeidas();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Obx(() {
                    final cargando = _notificacionCtrl.isLoading.value;
                    return IconButton(
                      tooltip: 'Recargar',
                      onPressed: cargando
                          ? null
                          : () {
                              final uid = _authCtrl.usuario.value?.id ?? '';
                              if (uid.isNotEmpty) _notificacionCtrl.cargarNotificaciones(uid);
                            },
                      icon: cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                            )
                          : Icon(Icons.refresh, size: 20, color: Colors.grey[700]),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 20),
            Expanded(
              child: Obx(() {
                final err = _notificacionCtrl.error.value;
                final lista = _notificacionCtrl.notificaciones;

                if (err.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(err, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
                    ),
                  );
                }

                if (_notificacionCtrl.isLoading.value && lista.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }

                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 58, color: Colors.grey[350]),
                        const SizedBox(height: 10),
                        Text(
                          'No tienes notificaciones',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller,
                  itemCount: lista.length,
                  itemBuilder: (_, i) => _NotifItemFromModel(
                    notificacion: lista[i],
                    onTap: () => _notificacionCtrl.marcarLeida(lista[i].id),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildInicio();
      case 1:
        return _ReservasTab(reservaCtrl: _reservaCtrl);
      case 2:
        return _PerfilTab(authCtrl: _authCtrl);
      default:
        return _buildInicio();
    }
  }

  // ── INICIO ─────────────────────────────────────────────────────────────────

  Widget _buildInicio() {
    return Column(
      children: [
        _buildBienvenida(),
        _buildEncabezado(),
        Expanded(
          child: Obx(() {
            if (_canchaCtrl.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]));
            }
            final canchas = _listaFinal;
            if (canchas.isEmpty) return _buildVacio();
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: canchas.length,
              itemBuilder: (_, i) {
                final cancha = canchas[i];
                return Obx(() => CanchaCard(
                      cancha: cancha,
                      mostrarFavorito: true,
                      esFavorito: _favoritoCtrl.esFavorito(cancha.id),
                      onToggleFavorito: () {
                        final uid = _authCtrl.usuario.value?.id ?? '';
                        if (uid.isNotEmpty) {
                          _favoritoCtrl.toggleFavorito(uid, cancha.id);
                        }
                      },
                    ));
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBienvenida() {
    return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Text('¡Hola, ${widget.nombreUsuario.split(' ').first}! ',
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text('¿Qué quieres reservar hoy?',
              style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      color: Colors.green[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: TextField(
              controller: _buscarCtrl,
              onChanged: _canchaCtrl.setBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar canchas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: Obx(() => _canchaCtrl.busqueda.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                        onPressed: () {
                          _buscarCtrl.clear();
                          _canchaCtrl.setBusqueda('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() => Row(
                  children: [
                    FiltroChip(
                      label: 'Cerca de mí',
                      icon: Icons.near_me_outlined,
                      activo: _canchaCtrl.soloCercanas.value,
                      onTap: _canchaCtrl.toggleCercanas,
                    ),
                    const SizedBox(width: 8),
                    _buildChipDeporte(),
                    const SizedBox(width: 8),
                    FiltroChip(
                      label: 'Favoritos',
                      icon: Icons.favorite_border,
                      activo: _soloFavoritos,
                      onTap: () => setState(() => _soloFavoritos = !_soloFavoritos),
                    ),
                    const SizedBox(width: 8),
                    FiltroChip(
                      label: 'Restablecer',
                      icon: Icons.refresh,
                      activo: false,
                      esRestablecer: true,
                      onTap: _restablecerFiltros,
                    ),
                  ],
                )),
          ),
          Obx(() {
            final total = _listaFinal.length;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                '$total canchas disponibles',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChipDeporte() {
    final seleccionado = _canchaCtrl.deporteFiltro.value;
    return GestureDetector(
      onTap: _mostrarSelectorDeporte,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado != null ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado != null ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined,
                size: 16,
                color: seleccionado != null ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              seleccionado ?? 'Deporte',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: seleccionado != null ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16,
                color: seleccionado != null ? Colors.white : Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _mostrarSelectorDeporte() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Seleccionar deporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            if (_canchaCtrl.deporteFiltro.value != null) {
              return ListTile(
                leading: Icon(Icons.close, color: Colors.red[400]),
                title: const Text('Todos los deportes'),
                onTap: () {
                  _canchaCtrl.setDeporte(null);
                  Navigator.pop(context);
                },
              );
            }
            return const SizedBox.shrink();
          }),
          ..._deportes.map((d) => Obx(() => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _canchaCtrl.deporteFiltro.value == d
                    ? Icon(Icons.check, color: Colors.green[700])
                    : null,
                onTap: () {
                  _canchaCtrl.setDeporte(d);
                  Navigator.pop(context);
                },
              ))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No se encontraron canchas',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _restablecerFiltros,
            child: Text('Restablecer filtros',
                style: TextStyle(color: Colors.green[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      selectedItemColor: Colors.green[700],
      unselectedItemColor: Colors.grey[500],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil'),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB RESERVAS
// ══════════════════════════════════════════════════════════════════════════════

class _ReservasTab extends StatelessWidget {
  final ReservaController reservaCtrl;

  const _ReservasTab({required this.reservaCtrl});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.green[600]!;
      case 'pendiente':
        return Colors.orange[600]!;
      case 'cancelada':
        return Colors.red[400]!;
      case 'completada':
        return Colors.blue[600]!;
      default:
        return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.green[50]!;
      case 'pendiente':
        return Colors.orange[50]!;
      case 'cancelada':
        return Colors.red[50]!;
      case 'completada':
        return Colors.blue[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return Icons.check_circle_outline;
      case 'pendiente':
        return Icons.hourglass_empty;
      case 'cancelada':
        return Icons.cancel_outlined;
      case 'completada':
        return Icons.sports_score;
      default:
        return Icons.info_outline;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return 'Confirmada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return estado;
    }
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (dia == hoy) return 'Hoy';
    if (dia == hoy.add(const Duration(days: 1))) return 'Mañana';
    const meses = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month]}';
  }

  String _fmt(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reservas = reservaCtrl.reservas;
      final filtradas = reservaCtrl.reservasFiltradas;
      final proximas = reservas.where((r) => r.estado == 'confirmada').length;
      final completadas = reservas.where((r) => r.estado == 'pendiente').length;

      return Column(
        children: [
          Container(
            color: Colors.green[100],
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MiniResumenCard(
                      valor: '$proximas',
                      label: 'Confirmadas',
                      color: Colors.green[700]!,
                      icono: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 10),
                    _MiniResumenCard(
                      valor: '$completadas',
                      label: 'Pendientes',
                      color: Colors.orange[600]!,
                      icono: Icons.hourglass_empty,
                    ),
                    const SizedBox(width: 10),
                    _MiniResumenCard(
                      valor: '${reservas.length}',
                      label: 'Total',
                      color: Colors.grey[700]!,
                      icono: Icons.calendar_month_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Todas',
                      'Confirmada',
                      'Pendiente',
                      'Rechazada',
                      'Cancelada'
                    ].map((f) {
                      final sel = reservaCtrl.filtroEstado.value == f;
                      return GestureDetector(
                        onTap: () => reservaCtrl.setFiltro(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.green[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel
                                    ? Colors.green[700]!
                                    : Colors.grey[300]!),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? Colors.white : Colors.grey[800])),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filtradas.length} reservas',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14)),
            ),
          ),

          Expanded(
            child: reservaCtrl.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: Colors.green[700]))
                : filtradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No hay reservas en esta categoría',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtradas.length,
                        itemBuilder: (_, i) =>
                            _ReservaCard(
                              reserva: filtradas[i],
                              reservaCtrl: reservaCtrl,
                              colorEstado: _colorEstado,
                              bgEstado: _bgEstado,
                              iconEstado: _iconEstado,
                              labelEstado: _labelEstado,
                              formatFecha: _formatFecha,
                              fmt: _fmt,
                            ),
                      ),
          ),
        ],
      );
    });
  }
}

class _ReservaCard extends StatefulWidget {
  final Reserva reserva;
  final ReservaController reservaCtrl;
  final Color Function(String) colorEstado;
  final Color Function(String) bgEstado;
  final IconData Function(String) iconEstado;
  final String Function(String) labelEstado;
  final String Function(DateTime) formatFecha;
  final String Function(double) fmt;

  const _ReservaCard({
    required this.reserva,
    required this.reservaCtrl,
    required this.colorEstado,
    required this.bgEstado,
    required this.iconEstado,
    required this.labelEstado,
    required this.formatFecha,
    required this.fmt,
  });

  @override
  State<_ReservaCard> createState() => _ReservaCardState();
}

class _ReservaCardState extends State<_ReservaCard> {
  final _calificacionCtrl = Get.find<CalificacionController>();
  final _authCtrl = Get.find<AuthController>();

  bool _yaCalificada = false;
  bool _verificando = true;

  @override
  void initState() {
    super.initState();
    _verificarCalificacion();
  }

  Future<void> _verificarCalificacion() async {
    final estado = widget.reserva.estado;
    if (estado != 'confirmada' && estado != 'completada') {
      if (mounted) setState(() => _verificando = false);
      return;
    }
    final uid = _authCtrl.usuario.value?.id ?? '';
    if (uid.isEmpty) {
      if (mounted) setState(() => _verificando = false);
      return;
    }
    final ya = await _calificacionCtrl.yaCalificada(uid, widget.reserva.id);
    if (mounted) setState(() { _yaCalificada = ya; _verificando = false; });
  }

  void _abrirCalificacion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalificacionSheet(
        reserva: widget.reserva,
        calificacionCtrl: _calificacionCtrl,
        authCtrl: _authCtrl,
        onCalificado: () {
          if (mounted) setState(() => _yaCalificada = true);
        },
      ),
    );
  }

  Widget _botonCalificar() {
    if (_verificando) return const Expanded(child: SizedBox.shrink());
    if (_yaCalificada) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 15, color: Colors.amber[700]),
              const SizedBox(width: 6),
              Text('Ya calificado',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800])),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _abrirCalificacion,
        icon: const Icon(Icons.star_outline, size: 15),
        label: const Text('Calificar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[400],
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.reserva.estado;
    final c = widget.colorEstado(estado);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.sports_outlined, color: c, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reserva.nombreCancha ?? 'Cancha',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Reserva #${widget.reserva.id.substring(0, 6)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: widget.bgEstado(estado),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.iconEstado(estado), size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(widget.labelEstado(estado),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: c)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.formatFecha(widget.reserva.fecha)}  ·  ${widget.reserva.horaInicio} – ${widget.reserva.horaFin}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    Text('\$${widget.fmt(widget.reserva.montoTotal)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700])),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Botones según estado ──────────────────────────────────
                if (estado == 'pendiente') ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            widget.reservaCtrl.cancelarReserva(widget.reserva.id),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final cancha = await Get.find<CanchaController>()
                              .obtenerCanchaPorId(widget.reserva.canchaId);
                          if (cancha != null) {
                            Get.toNamed('/disponibilidad', arguments: cancha);
                          }
                        },
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Ver cancha'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                ],
                if (estado == 'confirmada') ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            widget.reservaCtrl.cancelarReserva(widget.reserva.id),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final cancha = await Get.find<CanchaController>()
                              .obtenerCanchaPorId(widget.reserva.canchaId);
                          if (cancha != null) {
                            Get.toNamed('/disponibilidad', arguments: cancha);
                          }
                        },
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('Ver cancha'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [_botonCalificar()]),
                ],
                if (estado == 'completada') ...[
                  Row(children: [
                    _botonCalificar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/home'),
                        icon: const Icon(Icons.replay_outlined, size: 15),
                        label: const Text('Reservar de nuevo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
                ],
                if (estado == 'cancelada' || estado == 'rechazada')
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/home'),
                        icon: const Icon(Icons.add_circle_outline, size: 15),
                        label: const Text('Nueva reserva'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET CALIFICACIÓN
// ══════════════════════════════════════════════════════════════════════════════

class _CalificacionSheet extends StatefulWidget {
  final Reserva reserva;
  final CalificacionController calificacionCtrl;
  final AuthController authCtrl;
  final VoidCallback onCalificado;

  const _CalificacionSheet({
    required this.reserva,
    required this.calificacionCtrl,
    required this.authCtrl,
    required this.onCalificado,
  });

  @override
  State<_CalificacionSheet> createState() => _CalificacionSheetState();
}

class _CalificacionSheetState extends State<_CalificacionSheet> {
  int _puntuacion = 0;
  final _comentarioCtrl = TextEditingController();
  bool _enviando = false;

  static const _etiquetas = ['', 'Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente'];

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_puntuacion == 0) {
      Get.snackbar(
        'Elige una puntuación',
        'Selecciona entre 1 y 5 estrellas antes de enviar.',
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _enviando = true);
    final uid = widget.authCtrl.usuario.value?.id ?? '';
    final ok = await widget.calificacionCtrl.calificar(
      usuarioId: uid,
      canchaId: widget.reserva.canchaId,
      reservaId: widget.reserva.id,
      puntuacion: _puntuacion,
      comentario: _comentarioCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _enviando = false);
      if (ok) {
        Navigator.pop(context);
        widget.onCalificado();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('¿Cómo fue tu experiencia?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(
              widget.reserva.nombreCancha ?? 'Cancha',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            // ── Estrellas ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final estrella = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _puntuacion = estrella),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      estrella <= _puntuacion ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 48,
                      color: estrella <= _puntuacion ? Colors.amber[500] : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _puntuacion > 0
                  ? Padding(
                      key: ValueKey(_puntuacion),
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _etiquetas[_puntuacion],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700]),
                      ),
                    )
                  : const SizedBox(key: ValueKey(0), height: 8),
            ),
            const SizedBox(height: 20),
            // ── Comentario ──────────────────────────────────────────────
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia (opcional)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: Colors.grey[50],
                counterStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Botones ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _enviando ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _enviando ? null : _enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[500],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Enviar calificación',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB PERFIL
// ══════════════════════════════════════════════════════════════════════════════

class _PerfilTab extends StatelessWidget {
  final AuthController authCtrl;

  const _PerfilTab({required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final usuario = authCtrl.usuario.value;
      final nombre = usuario?.nombre ?? '';
      final email = usuario?.email ?? '';
      final telefono = usuario?.telefono ?? '';

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.green[300],
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.greenAccent[400],
                              shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(nombre,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SeccionPerfil(titulo: 'Información personal', items: [
                    _InfoItem(
                        icono: Icons.person_outline,
                        label: 'Nombre',
                        valor: nombre.isNotEmpty ? nombre : '—'),
                    _InfoItem(
                        icono: Icons.phone_outlined,
                        label: 'Teléfono',
                        valor: telefono.isNotEmpty ? telefono : '—'),
                    _InfoItem(
                        icono: Icons.email_outlined,
                        label: 'Correo',
                        valor: email.isNotEmpty ? email : '—'),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _OpcionItem(
                      icono: Icons.lock_outline,
                      label: 'Cambiar contraseña',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.help_outline,
                      label: 'Ayuda y soporte',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.policy_outlined,
                      label: 'Términos y condiciones',
                      onTap: () {}),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => authCtrl.logout(),
                      icon: Icon(Icons.logout, color: Colors.red[600]),
                      label: Text('Cerrar sesión',
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS DE APOYO
// ══════════════════════════════════════════════════════════════════════════════

class _MiniResumenCard extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;
  final IconData icono;

  const _MiniResumenCard(
      {required this.valor,
      required this.label,
      required this.color,
      required this.icono});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 4),
            Text(valor,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SeccionPerfil extends StatelessWidget {
  final String titulo;
  final List<Widget> items;

  const _SeccionPerfil({required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(titulo,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoItem(
      {required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icono, size: 20, color: Colors.green[700]),
      title: Text(label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(valor,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}

class _OpcionItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _OpcionItem(
      {required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: ListTile(
        leading: Icon(icono, color: Colors.green[700], size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

class _NotifItemFromModel extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onTap;

  const _NotifItemFromModel({required this.notificacion, required this.onTap});

  IconData _icono(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reserva':
        return Icons.calendar_today_outlined;
      case 'calificacion':
        return Icons.star_outline;
      case 'pago':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _color(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reserva':
        return Colors.green;
      case 'calificacion':
        return Colors.amber;
      case 'pago':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(notificacion.tipo);
    final icono = _icono(notificacion.tipo);
    final esNoLeida = !notificacion.leida;

    return Container(
      color: esNoLeida ? Colors.green.withValues(alpha: 0.06) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notificacion.titulo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: esNoLeida ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (esNoLeida)
              const SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacion.mensaje, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(_tiempoRelativo(notificacion.fecha), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
