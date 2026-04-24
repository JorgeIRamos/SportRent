import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/favorito_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/home/home_widgets.dart';
import 'home_usuario_widgets.dart';
import 'perfil_tab_usuario.dart';
import 'reservas_tab_usuario.dart';

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
  Worker? _tabWorker;

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
    _tabWorker = ever(_reservaCtrl.tabSolicitud, (tab) {
      if (tab >= 0 && mounted) {
        setState(() => _navIndex = tab);
        _reservaCtrl.tabSolicitud.value = -1;
      }
    });
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
    _tabWorker?.dispose();
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
      case 1: return 'Mis Reservas';
      case 2: return 'Mi Perfil';
      default: return '';
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
                      const Text('SportRent',
                          style: TextStyle(
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
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text('Notificaciones',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Obx(() {
                    final cargando = _notificacionCtrl.isLoading.value;
                    return IconButton(
                      tooltip: 'Recargar',
                      onPressed: cargando
                          ? null
                          : () {
                              final uid = _authCtrl.usuario.value?.id ?? '';
                              if (uid.isNotEmpty) {
                                _notificacionCtrl.cargarNotificaciones(uid);
                              }
                            },
                      icon: cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.green),
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
                      child: Text(err,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[700])),
                    ),
                  );
                }

                if (_notificacionCtrl.isLoading.value && lista.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
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
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller,
                  itemCount: lista.length,
                  itemBuilder: (_, i) => NotifItemUsuario(
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
      case 0: return _buildInicio();
      case 1: return ReservasTabUsuario(reservaCtrl: _reservaCtrl);
      case 2: return PerfilTabUsuario(authCtrl: _authCtrl);
      default: return _buildInicio();
    }
  }

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
