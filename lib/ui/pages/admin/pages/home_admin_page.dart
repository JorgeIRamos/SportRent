import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/ui/pages/admin/widgets/admin_canchas_body.dart';
import 'package:sport_rent/ui/pages/admin/widgets/admin_empresas_body.dart';
import 'package:sport_rent/ui/pages/admin/widgets/admin_inicio_body.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _empresaCtrl = Get.find<EmpresaController>();
  final _authCtrl = Get.find<AuthController>();

  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _canchaCtrl.cargarCanchas();
    _empresaCtrl.cargarTodasEmpresas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined,
                color: Colors.green[800], size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Panel Admin',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text('SportRent',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          Obx(() {
            final pendientes =
                _empresaCtrl.todasEmpresas.where((e) => !e.verificada).length;
            if (pendientes == 0) return const SizedBox.shrink();
            return Stack(
              children: [
                IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => setState(() => _navIndex = 2)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$pendientes',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _authCtrl.logout(),
            tooltip: 'Cerrar sesión',
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
        return AdminInicioBody(
            onVerCanchas: () => setState(() => _navIndex = 1));
      case 1:
        return const AdminCanchasBody();
      case 2:
        return const AdminEmpresasBody();
      default:
        return AdminInicioBody(
            onVerCanchas: () => setState(() => _navIndex = 1));
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Resumen'),
        BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: 'Canchas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Empresas'),
      ],
    );
  }
}
