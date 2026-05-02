import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/ui/pages/canchas/pages/registrar_canchas_page.dart';
import 'package:sport_rent/ui/pages/empresa/tabs/estadisticas_tab.dart';
import 'package:sport_rent/ui/pages/empresa/tabs/perfil_tab_empresa.dart';
import 'package:sport_rent/ui/pages/empresa/tabs/reservas_tab_empresa.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/empresa_inicio_body.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/empresa_notificaciones_sheet.dart';

class HomeEmpresa extends StatefulWidget {
  const HomeEmpresa({super.key});

  @override
  State<HomeEmpresa> createState() => _HomeEmpresaState();
}

class _HomeEmpresaState extends State<HomeEmpresa> {
  int _navIndex = 0;

  late final CanchaController _canchaCtrl;
  late final ReservaController _reservaCtrl;
  late final EmpresaController _empresaCtrl;
  late final NotificacionController _notificacionCtrl;

  @override
  void initState() {
    super.initState();
    _canchaCtrl = Get.find<CanchaController>();
    _reservaCtrl = Get.find<ReservaController>();
    _empresaCtrl = Get.find<EmpresaController>();
    _notificacionCtrl = Get.find<NotificacionController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Get.find<AuthController>();
      final empresaId = auth.empresaId;
      final uid = auth.usuario.value?.id ?? '';
      if (empresaId.isEmpty) return;
      _canchaCtrl.cargarCanchas(empresaId: empresaId);
      _reservaCtrl.cargarReservasEmpresa(empresaId);
      _empresaCtrl.cargarEmpresa(empresaId);
      if (uid.isNotEmpty) _notificacionCtrl.cargarNotificaciones(uid);
    });
  }

  String get _appBarTitle {
    switch (_navIndex) {
      case 1:
        return 'Reservas';
      case 2:
        return 'Estadísticas';
      case 3:
        return 'Mi Perfil';
      default:
        final empresa = Get.find<EmpresaController>();
        return empresa.nombreEmpresa.isNotEmpty
            ? empresa.nombreEmpresa
            : 'Mi Empresa';
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
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_appBarTitle,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                if (_navIndex == 0)
                  Row(
                    children: [
                      Icon(
                        _empresaCtrl.estaVerificada
                            ? Icons.verified
                            : Icons.hourglass_top,
                        size: 13,
                        color: _empresaCtrl.estaVerificada
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _empresaCtrl.estaVerificada
                            ? 'Empresa verificada'
                            : 'Empresa sin aprobar',
                        style: TextStyle(
                          fontSize: 11,
                          color: _empresaCtrl.estaVerificada
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
              ],
            )),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black),
                onPressed: () =>
                    mostrarNotificacionesEmpresa(context, _notificacionCtrl),
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
                    child: Text('$n',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Obx(() => _navIndex == 0 && _empresaCtrl.estaVerificada
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegistrarCancha())),
              backgroundColor: Colors.greenAccent[400],
              foregroundColor: Colors.black87,
              icon: const Icon(Icons.add),
              label: const Text('Añadir cancha',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : const SizedBox.shrink()),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return const EmpresaInicioBody();
      case 1:
        return const ReservasTabEmpresa();
      case 2:
        return const EstadisticasTab();
      case 3:
        return const PerfilTabEmpresa();
      default:
        return const EmpresaInicioBody();
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil'),
      ],
    );
  }
}
