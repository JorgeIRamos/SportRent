import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'home_admin_widgets.dart';

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
  String? _filtroDeporte;
  String _buscar = '';
  final _buscarCtrl = TextEditingController();

  static const _deportes = [
    'Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'
  ];

  @override
  void initState() {
    super.initState();
    _canchaCtrl.cargarCanchas();
    _empresaCtrl.cargarTodasEmpresas();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  List<Cancha> get _canchasFiltradas {
    return _canchaCtrl.canchas.where((c) {
      if (_filtroDeporte != null && c.tipoDeporte != _filtroDeporte) return false;
      if (_buscar.isNotEmpty &&
          !c.nombre.toLowerCase().contains(_buscar.toLowerCase()) &&
          !c.direccion.toLowerCase().contains(_buscar.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
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
        return _buildInicio();
      case 1:
        return _buildCanchas();
      case 2:
        return _buildEmpresas();
      default:
        return _buildInicio();
    }
  }

  // ── RESUMEN ──────────────────────────────────────────────────────────────────

  Widget _buildInicio() {
    return Obx(() {
      final canchas = _canchaCtrl.canchas;
      final activas = canchas.where((c) => c.activa).length;
      final empresas = _empresaCtrl.todasEmpresas;
      final pendientesVerif = empresas.where((e) => !e.verificada).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen general',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              children: [
                AdminStatCard(
                    label: 'Total canchas',
                    valor: '${canchas.length}',
                    icono: Icons.sports_soccer,
                    color: Colors.green[700]!),
                const SizedBox(width: 10),
                AdminStatCard(
                    label: 'Activas',
                    valor: '$activas',
                    icono: Icons.check_circle_outline,
                    color: Colors.teal[600]!),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                AdminStatCard(
                    label: 'Empresas',
                    valor: '${empresas.length}',
                    icono: Icons.business_outlined,
                    color: Colors.blue[700]!),
                const SizedBox(width: 10),
                AdminStatCard(
                    label: 'Sin verificar',
                    valor: '${pendientesVerif.length}',
                    icono: Icons.pending_outlined,
                    color: Colors.orange[700]!),
              ],
            ),
            if (pendientesVerif.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.pending_actions, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  const Text('Empresas pendientes de verificación',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 10),
              ...pendientesVerif.map((e) => EmpresaPendienteCard(
                    empresa: e,
                    onAprobar: () => _empresaCtrl.verificarEmpresa(e.id),
                    onRechazar: () => _empresaCtrl.rechazarEmpresa(e.id),
                  )),
            ],
            const SizedBox(height: 24),
            const Text('Canchas recientes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...canchas.take(2).map((c) => CanchaAdminRow(
                  cancha: c,
                  onToggle: () => _canchaCtrl.toggleActiva(c.id),
                )),
            TextButton(
              onPressed: () => setState(() => _navIndex = 1),
              child: Text('Ver todas las canchas',
                  style: TextStyle(color: Colors.green[700])),
            ),
          ],
        ),
      );
    });
  }

  // ── CANCHAS ──────────────────────────────────────────────────────────────────

  Widget _buildCanchas() {
    return Column(
      children: [
        Container(
          color: Colors.green[100],
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: _buscarCtrl,
                onChanged: (v) => setState(() => _buscar = v),
                decoration: InputDecoration(
                  hintText: 'Buscar cancha o dirección...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _buscar.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _buscarCtrl.clear();
                            setState(() => _buscar = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _deportes.map((d) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(d),
                          selected: _filtroDeporte == d,
                          selectedColor: Colors.green[700],
                          labelStyle: TextStyle(
                            color: _filtroDeporte == d
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setState(() =>
                              _filtroDeporte = _filtroDeporte == d ? null : d),
                        ),
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final canchas = _canchasFiltradas;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${canchas.length} canchas',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          );
        }),
        Expanded(
          child: Obx(() {
            final canchas = _canchasFiltradas;
            if (_canchaCtrl.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]));
            }
            if (canchas.isEmpty) {
              return Center(
                  child: Text('No se encontraron canchas',
                      style: TextStyle(color: Colors.grey[600])));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: canchas.length,
              itemBuilder: (_, i) => CanchaAdminRow(
                cancha: canchas[i],
                onToggle: () => _canchaCtrl.toggleActiva(canchas[i].id),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── EMPRESAS ─────────────────────────────────────────────────────────────────

  Widget _buildEmpresas() {
    return Obx(() {
      final empresas = _empresaCtrl.todasEmpresas;
      final pendientes = empresas.where((e) => !e.verificada).toList();

      if (_empresaCtrl.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Colors.green[700]));
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Todas las empresas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (pendientes.isNotEmpty) ...[
            Text('Pendientes de verificación (${pendientes.length})',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700])),
            const SizedBox(height: 8),
            ...pendientes.map((e) => EmpresaPendienteCard(
                  empresa: e,
                  onAprobar: () => _empresaCtrl.verificarEmpresa(e.id),
                  onRechazar: () => _empresaCtrl.rechazarEmpresa(e.id),
                )),
            const SizedBox(height: 16),
            const Text('Todas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
          ...empresas.map((e) => EmpresaRow(empresa: e)),
        ],
      );
    });
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
