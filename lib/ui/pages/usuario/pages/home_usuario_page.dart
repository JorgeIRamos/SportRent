import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/favorito_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/ui/pages/usuario/tabs/perfil_tab_usuario.dart';
import 'package:sport_rent/ui/pages/usuario/tabs/reservas_tab_usuario.dart';
import 'package:sport_rent/ui/pages/usuario/widgets/usuario_inicio_body.dart';
import 'package:sport_rent/ui/pages/usuario/widgets/usuario_notificaciones_sheet.dart';

class HomeUsuario extends StatefulWidget {
  final String nombreUsuario;

  const HomeUsuario({super.key, required this.nombreUsuario});

  @override
  State<HomeUsuario> createState() => _HomeUsuarioState();
}

class _HomeUsuarioState extends State<HomeUsuario> {
  final _reservaCtrl = Get.find<ReservaController>();
  final _authCtrl = Get.find<AuthController>();
  final _favoritoCtrl = Get.find<FavoritoController>();
  final _notificacionCtrl = Get.find<NotificacionController>();

  int _navIndex = 0;
  Worker? _uidWorker;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
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
    _uidWorker?.dispose();
    _tabWorker?.dispose();
    super.dispose();
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
                  Icon(Icons.location_on_outlined,
                      color: Colors.green[700], size: 20),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black),
                onPressed: () =>
                    mostrarNotificacionesUsuario(context, _notificacionCtrl),
              ),
              Obx(() {
                final n = _notificacionCtrl.totalNoLeidas;
                if (n <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$n',
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
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

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return UsuarioInicioBody(nombreUsuario: widget.nombreUsuario);
      case 1:
        return ReservasTabUsuario(reservaCtrl: _reservaCtrl);
      case 2:
        return PerfilTabUsuario(authCtrl: _authCtrl);
      default:
        return UsuarioInicioBody(nombreUsuario: widget.nombreUsuario);
    }
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
