import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/home/home_widgets.dart';
import 'package:sport_rent/ui/pages/registrar_canchas/registrar_canchas_page.dart';
import 'estadisticas_tab.dart';
import 'home_empresa_widgets.dart';
import 'perfil_tab_empresa.dart';
import 'reservas_tab_empresa.dart';

class HomeEmpresa extends StatefulWidget {
  const HomeEmpresa({super.key});

  @override
  State<HomeEmpresa> createState() => _HomeEmpresaState();
}

class _HomeEmpresaState extends State<HomeEmpresa> {
  final TextEditingController _buscarCtrl = TextEditingController();
  String? _deporteSeleccionado;
  int _navIndex = 0;

  late final CanchaController _canchaCtrl;
  late final ReservaController _reservaCtrl;
  late final EmpresaController _empresaCtrl;
  late final NotificacionController _notificacionCtrl;

  final List<String> _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  List<Cancha> get _canchasFiltradas {
    return _canchaCtrl.canchas.where((c) {
      if (_deporteSeleccionado != null && c.tipoDeporte != _deporteSeleccionado) return false;
      if (_buscarCtrl.text.isNotEmpty &&
          !c.nombre.toLowerCase().contains(_buscarCtrl.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void _restablecerFiltros() {
    setState(() {
      _deporteSeleccionado = null;
      _buscarCtrl.clear();
    });
  }

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

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    switch (_navIndex) {
      case 1: return 'Reservas';
      case 2: return 'Estadísticas';
      case 3: return 'Mi Perfil';
      default:
        final empresa = Get.find<EmpresaController>();
        return empresa.nombreEmpresa.isNotEmpty ? empresa.nombreEmpresa : 'Mi Empresa';
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            if (_navIndex == 0)
              Row(
                children: [
                  Icon(
                    _empresaCtrl.estaVerificada ? Icons.verified : Icons.hourglass_top,
                    size: 13,
                    color: _empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _empresaCtrl.estaVerificada ? 'Empresa verificada' : 'Empresa sin aprobar',
                    style: TextStyle(
                      fontSize: 11,
                      color: _empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
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
                    child: Text('$n',
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
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
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RegistrarCancha())),
              backgroundColor: Colors.greenAccent[400],
              foregroundColor: Colors.black87,
              icon: const Icon(Icons.add),
              label: const Text('Añadir cancha', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : const SizedBox.shrink()),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0: return _buildInicio();
      case 1: return const ReservasTabEmpresa();
      case 2: return const EstadisticasTab();
      case 3: return const PerfilTabEmpresa();
      default: return _buildInicio();
    }
  }

  Widget _buildInicio() {
    return Obx(() {
      if (_canchaCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.green));
      }
      final canchas = _canchasFiltradas;
      final hoy = DateTime.now();
      final reservasHoy = _reservaCtrl.reservas.where((r) =>
          r.fecha.year == hoy.year &&
          r.fecha.month == hoy.month &&
          r.fecha.day == hoy.day).length;
      return Column(
        children: [
          _buildResumen(canchas, reservasHoy),
          _buildEncabezado(),
          Expanded(
            child: canchas.isEmpty
                ? _buildVacio()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: canchas.length,
                    itemBuilder: (ctx, i) => CanchaEmpresaCard(
                      cancha: canchas[i],
                      onToggleActiva: () => _canchaCtrl.toggleActiva(canchas[i].id),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildResumen(List<Cancha> canchas, int reservasHoy) {
    return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          StatCardEmpresa(label: 'Mis canchas', valor: '${canchas.length}',
              icono: Icons.sports_soccer, color: Colors.green[700]!),
          const SizedBox(width: 10),
          StatCardEmpresa(
              label: 'Activas',
              valor: '${canchas.where((c) => c.activa).length}',
              icono: Icons.check_circle_outline,
              color: Colors.teal[600]!),
          const SizedBox(width: 10),
          StatCardEmpresa(label: 'Reservas hoy', valor: '$reservasHoy',
              icono: Icons.calendar_today_outlined, color: Colors.orange[700]!),
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
          if (!_empresaCtrl.estaVerificada)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.hourglass_top, color: Colors.orange[800], size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pendiente de aprobación',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Tu empresa aún no ha sido aprobada. No puedes registrar canchas ni gestionar reservas.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _buscarCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar en mis canchas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _buscarCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                        onPressed: () => setState(() => _buscarCtrl.clear()))
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildChipDeporte(),
                const SizedBox(width: 8),
                FiltroChip(
                    label: 'Restablecer',
                    icon: Icons.refresh,
                    activo: false,
                    esRestablecer: true,
                    onTap: _restablecerFiltros),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text('${_canchasFiltradas.length} canchas encontradas',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipDeporte() {
    return GestureDetector(
      onTap: _mostrarSelectorDeporte,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _deporteSeleccionado != null ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _deporteSeleccionado != null ? Colors.green[700]! : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined, size: 16,
                color: _deporteSeleccionado != null ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(_deporteSeleccionado ?? 'Tipo de deporte',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _deporteSeleccionado != null ? Colors.white : Colors.grey[800])),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16,
                color: _deporteSeleccionado != null ? Colors.white : Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _mostrarSelectorDeporte() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Filtrar por deporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_deporteSeleccionado != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: const Text('Todos los deportes'),
              onTap: () { setState(() => _deporteSeleccionado = null); Navigator.pop(context); },
            ),
          ..._deportes.map((d) => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _deporteSeleccionado == d ? Icon(Icons.check, color: Colors.green[700]) : null,
                onTap: () { setState(() => _deporteSeleccionado = d); Navigator.pop(context); },
              )),
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
          Icon(Icons.sports_soccer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No se encontraron canchas', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
              onPressed: _restablecerFiltros,
              child: Text('Restablecer filtros', style: TextStyle(color: Colors.green[700]))),
        ],
      ),
    );
  }

  void _mostrarNotificaciones(BuildContext context) {
    _notificacionCtrl.marcarTodasLeidas();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
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
                              final uid = Get.find<AuthController>().usuario.value?.id ?? '';
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
                        Text('No tienes notificaciones',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller,
                  itemCount: lista.length,
                  itemBuilder: (_, i) => NotifItemFromModel(
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
            icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
