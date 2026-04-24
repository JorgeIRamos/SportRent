import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/models/notificacion_model.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/ui/pages/home.dart';
import 'package:sport_rent/ui/pages/registrar_canchas.dart';

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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            if (_navIndex == 0)
              Row(
                children: [
                  Icon(
                    _empresaCtrl.estaVerificada ? Icons.verified : Icons.hourglass_top,
                    size: 13,
                    color: _empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                  ),
                  SizedBox(width: 3),
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
                icon: Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () => _mostrarNotificaciones(context),
              ),
              Obx(() {
                final n = _notificacionCtrl.totalNoLeidas;
                if (n <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$n',
                        style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
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
              icon: Icon(Icons.add),
              label: Text('Añadir cancha', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : const SizedBox.shrink()),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0: return _buildInicio();
      case 1: return const _ReservasTab();
      case 2: return const _EstadisticasTab();
      case 3: return _PerfilTab();
      default: return _buildInicio();
    }
  }

  // ── INICIO ────────────────────────────────────────────────────────────────

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
                    padding: EdgeInsets.only(bottom: 90),
                    itemCount: canchas.length,
                    itemBuilder: (ctx, i) => _CanchaEmpresaCard(
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _StatCard(label: 'Mis canchas', valor: '${canchas.length}',
              icono: Icons.sports_soccer, color: Colors.green[700]!),
          SizedBox(width: 10),
          _StatCard(
              label: 'Activas',
              valor: '${canchas.where((c) => c.activa).length}',
              icono: Icons.check_circle_outline,
              color: Colors.teal[600]!),
          SizedBox(width: 10),
          _StatCard(label: 'Reservas hoy', valor: '$reservasHoy',
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
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildChipDeporte(),
                SizedBox(width: 8),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipDeporte() {
    return GestureDetector(
      onTap: _mostrarSelectorDeporte,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            SizedBox(width: 6),
            Text(_deporteSeleccionado ?? 'Tipo de deporte',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _deporteSeleccionado != null ? Colors.white : Colors.grey[800])),
            SizedBox(width: 4),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          SizedBox(height: 16),
          Text('Filtrar por deporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (_deporteSeleccionado != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: Text('Todos los deportes'),
              onTap: () { setState(() => _deporteSeleccionado = null); Navigator.pop(context); },
            ),
          ..._deportes.map((d) => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _deporteSeleccionado == d ? Icon(Icons.check, color: Colors.green[700]) : null,
                onTap: () { setState(() => _deporteSeleccionado = d); Navigator.pop(context); },
              )),
          SizedBox(height: 16),
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
          SizedBox(height: 12),
          Text('No se encontraron canchas', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 8),
          TextButton(
              onPressed: _restablecerFiltros,
              child: Text('Restablecer filtros', style: TextStyle(color: Colors.green[700]))),
        ],
      ),
    );
  }

  // ── NOTIFICACIONES ────────────────────────────────────────────────────────

  void _mostrarNotificaciones(BuildContext context) {
    _notificacionCtrl.marcarTodasLeidas();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.green[700]),
                  SizedBox(width: 8),
                  Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          ? SizedBox(
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
            Divider(height: 20),
            Expanded(
              child: Obx(() {
                final err = _notificacionCtrl.error.value;
                final lista = _notificacionCtrl.notificaciones;

                if (err.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                        SizedBox(height: 10),
                        Text('No tienes notificaciones',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
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

  // ── NAV BAR ───────────────────────────────────────────────────────────────

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

// ══════════════════════════════════════════════════════════════════════════════
// TAB RESERVAS
// ══════════════════════════════════════════════════════════════════════════════

class _ReservasTab extends StatefulWidget {
  const _ReservasTab();

  @override
  State<_ReservasTab> createState() => _ReservasTabState();
}

class _ReservasTabState extends State<_ReservasTab> {
  final _ctrl = Get.find<ReservaController>();

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[600]!;
      case 'pendiente':  return Colors.orange[600]!;
      case 'cancelada':  return Colors.red[400]!;
      case 'rechazada':  return Colors.red[700]!;
      case 'completada': return Colors.blue[600]!;
      default: return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green[50]!;
      case 'pendiente':  return Colors.orange[50]!;
      case 'cancelada':  return Colors.red[50]!;
      case 'rechazada':  return Colors.red[50]!;
      case 'completada': return Colors.blue[50]!;
      default: return Colors.grey[100]!;
    }
  }

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatFecha(DateTime fecha) {
    final hoy = DateTime.now();
    if (fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day) {
      return 'Hoy';
    }
    final man = hoy.add(const Duration(days: 1));
    if (fecha.year == man.year && fecha.month == man.month && fecha.day == man.day) {
      return 'Mañana';
    }
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  String _fmt(int v) {
    final s = v.toString();
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
      final lista = _ctrl.reservasFiltradas;
      final filtro = _ctrl.filtroEstado.value;
      final empresaVerificada = Get.find<EmpresaController>().estaVerificada;
      return Column(
        children: [
          Container(
            color: Colors.green[100],
            padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _MiniStat(valor: '${_ctrl.totalConfirmadas}', label: 'Confirm.', color: Colors.green[600]!),
                    SizedBox(width: 8),
                    _MiniStat(valor: '${_ctrl.totalPendientes}', label: 'Pendientes', color: Colors.orange[600]!),
                    SizedBox(width: 8),
                    _MiniStat(valor: '${_ctrl.totalCanceladas}', label: 'Canceladas', color: Colors.red[400]!),
                    SizedBox(width: 8),
                    _MiniStat(valor: '${_ctrl.reservas.length}', label: 'Total', color: Colors.green[800]!),
                  ],
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Confirmada', 'Pendiente', 'Cancelada', 'Rechazada'].map((f) {
                      final sel = filtro == f;
                      return GestureDetector(
                        onTap: () => _ctrl.setFiltro(f),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.green[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? Colors.green[700]! : Colors.grey[300]!),
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
            padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${lista.length} reservas',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          ),
          if (_ctrl.isLoading.value)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.green)))
          else
            Expanded(
              child: lista.isEmpty
                  ? Center(child: Text('No hay reservas', style: TextStyle(color: Colors.grey[500])))
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: lista.length,
                      itemBuilder: (_, i) {
                        final Reserva r = lista[i];
                        final String estado = r.estado;
                        return Container(
                          margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Icon(Icons.sports_soccer_outlined, color: Colors.green[700]),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Reserva #${r.id.substring(0, 6)}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                          SizedBox(height: 6),
                                          Text(r.nombreCliente ?? 'Cliente desconocido',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          SizedBox(height: 4),
                                          Text('Cancha: ${r.nombreCancha ?? r.canchaId}',
                                              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: _bgEstado(estado),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Text(_capitalizar(estado),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _colorEstado(estado),
                                          )),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                                    SizedBox(width: 6),
                                    Expanded(child: Text('${_formatFecha(r.fecha)} · ${r.horaInicio} – ${r.horaFin}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('Total: \$${_fmt(r.montoTotal.toInt())}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                if (!empresaVerificada) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Empresa pendiente de aprobación. No puedes gestionar reservas.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ] else if (estado == 'pendiente') ...[
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _ctrl.rechazarReserva(r.id),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red[700],
                                            side: BorderSide(color: Colors.red[200]!),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: Text('Rechazar reserva'),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _ctrl.confirmarReserva(r.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: Text('Aceptar reserva'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (estado == 'confirmada') ...[
                                  SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => _ctrl.cancelarReserva(r.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red[700],
                                      side: BorderSide(color: Colors.red[200]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text('Cancelar reserva'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB ESTADÍSTICAS
// ══════════════════════════════════════════════════════════════════════════════

class _EstadisticasTab extends StatefulWidget {
  const _EstadisticasTab();

  @override
  State<_EstadisticasTab> createState() => _EstadisticasTabState();
}

class _EstadisticasTabState extends State<_EstadisticasTab> {
  String _periodo = 'Semana';
  String? _filtroCancha;
  DateTime _fechaRef = DateTime.now();

  late final ReservaController _reservaCtrl;
  late final CanchaController _canchaCtrl;

  static const _meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  static const _mesesCortos = ['ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.',
      'jul.', 'ago.', 'sep.', 'oct.', 'nov.', 'dic.'];

  List<String> get _canchas =>
      _canchaCtrl.canchas.map((c) => c.nombre).toSet().toList();

  String get _etiquetaPeriodo {
    switch (_periodo) {
      case 'Día':
        return '${_fechaRef.day} ${_mesesCortos[_fechaRef.month - 1]} ${_fechaRef.year}';
      case 'Semana':
        final lunes = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day)
            .subtract(Duration(days: _fechaRef.weekday - 1));
        final domingo = lunes.add(Duration(days: 6));
        if (lunes.month == domingo.month) {
          return '${lunes.day} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
        }
        if (lunes.year == domingo.year) {
          return '${lunes.day} ${_mesesCortos[lunes.month - 1]} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
        }
        return '${lunes.day} ${_mesesCortos[lunes.month - 1]} ${lunes.year} – ${domingo.day} ${_mesesCortos[domingo.month - 1]} ${domingo.year}';
      case 'Año':
        return '${_fechaRef.year}';
      case 'Mes':
      default:
        return '${_meses[_fechaRef.month - 1]} ${_fechaRef.year}';
    }
  }

  void _irAntes() {
    setState(() {
      switch (_periodo) {
        case 'Día':
          _fechaRef = _fechaRef.subtract(Duration(days: 1));
          break;
        case 'Semana':
          _fechaRef = _fechaRef.subtract(Duration(days: 7));
          break;
        case 'Año':
          _fechaRef = DateTime(_fechaRef.year - 1, 1, 1);
          break;
        case 'Mes':
          _fechaRef = DateTime(_fechaRef.year, _fechaRef.month - 1, 1);
          break;
      }
    });
  }

  void _irAdelante() {
    setState(() {
      switch (_periodo) {
        case 'Día':
          _fechaRef = _fechaRef.add(Duration(days: 1));
          break;
        case 'Semana':
          _fechaRef = _fechaRef.add(Duration(days: 7));
          break;
        case 'Año':
          _fechaRef = DateTime(_fechaRef.year + 1, 1, 1);
          break;
        case 'Mes':
          _fechaRef = DateTime(_fechaRef.year, _fechaRef.month + 1, 1);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _reservaCtrl = Get.find<ReservaController>();
    _canchaCtrl = Get.find<CanchaController>();
  }

  List<Reserva> get _reservasPeriodo {
    DateTime inicio;
    DateTime fin;
    switch (_periodo) {
      case 'Día':
        inicio = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day);
        fin = inicio.add(Duration(days: 1));
        break;
      case 'Semana':
        inicio = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day)
            .subtract(Duration(days: _fechaRef.weekday - 1));
        fin = inicio.add(Duration(days: 7));
        break;
      case 'Año':
        inicio = DateTime(_fechaRef.year, 1, 1);
        fin = DateTime(_fechaRef.year + 1, 1, 1);
        break;
      case 'Mes':
      default:
        inicio = DateTime(_fechaRef.year, _fechaRef.month, 1);
        fin = DateTime(_fechaRef.year, _fechaRef.month + 1, 1);
    }
    return _reservaCtrl.reservas.where((r) {
      if (r.fecha.isBefore(inicio) || !r.fecha.isBefore(fin)) return false;
      if (_filtroCancha != null && r.nombreCancha != _filtroCancha) return false;
      return true;
    }).toList();
  }

  List<double> get _datosReservas {
    final reservas = _reservasPeriodo;
    switch (_periodo) {
      case 'Día':
        final counts = List.filled(12, 0.0);
        for (final r in reservas) {
          final hora = int.tryParse(r.horaInicio.split(':')[0]) ?? 0;
          final idx = hora - 6;
          if (idx >= 0 && idx < 12) counts[idx]++;
        }
        return counts;
      case 'Semana':
        final inicioSemana = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day)
            .subtract(Duration(days: _fechaRef.weekday - 1));
        final counts = List.filled(7, 0.0);
        for (final r in reservas) {
          final diff = DateTime(r.fecha.year, r.fecha.month, r.fecha.day)
              .difference(inicioSemana)
              .inDays;
          if (diff >= 0 && diff < 7) counts[diff]++;
        }
        return counts;
      case 'Año':
        final counts = List.filled(12, 0.0);
        for (final r in reservas) {
          counts[r.fecha.month - 1]++;
        }
        return counts;
      case 'Mes':
      default:
        final counts = List.filled(4, 0.0);
        for (final r in reservas) {
          final semana = ((r.fecha.day - 1) ~/ 7).clamp(0, 3);
          counts[semana]++;
        }
        return counts;
    }
  }

  List<double> get _datosIngresos {
    final reservas = _reservasPeriodo
        .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
        .toList();
    switch (_periodo) {
      case 'Día':
        final sums = List.filled(12, 0.0);
        for (final r in reservas) {
          final hora = int.tryParse(r.horaInicio.split(':')[0]) ?? 0;
          final idx = hora - 6;
          if (idx >= 0 && idx < 12) sums[idx] += r.montoTotal;
        }
        return sums;
      case 'Semana':
        final inicioSemana = DateTime(_fechaRef.year, _fechaRef.month, _fechaRef.day)
            .subtract(Duration(days: _fechaRef.weekday - 1));
        final sums = List.filled(7, 0.0);
        for (final r in reservas) {
          final diff = DateTime(r.fecha.year, r.fecha.month, r.fecha.day)
              .difference(inicioSemana)
              .inDays;
          if (diff >= 0 && diff < 7) sums[diff] += r.montoTotal;
        }
        return sums;
      case 'Año':
        final sums = List.filled(12, 0.0);
        for (final r in reservas) {
          sums[r.fecha.month - 1] += r.montoTotal;
        }
        return sums;
      case 'Mes':
      default:
        final sums = List.filled(4, 0.0);
        for (final r in reservas) {
          final semana = ((r.fecha.day - 1) ~/ 7).clamp(0, 3);
          sums[semana] += r.montoTotal;
        }
        return sums;
    }
  }

  List<String> get _etiquetas {
    switch (_periodo) {
      case 'Día': return ['6h','7h','8h','9h','10h','11h','12h','13h','14h','15h','16h','17h'];
      case 'Semana': return ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
      case 'Año':
        return ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      case 'Mes':
      default: return ['Sem 1','Sem 2','Sem 3','Sem 4'];
    }
  }

  double get _totalIngresos => _reservasPeriodo
      .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
      .fold(0.0, (a, r) => a + r.montoTotal);

  double get _totalReservas => _reservasPeriodo.length.toDouble();

  double get _ocupacion {
    final total = _reservasPeriodo.length;
    if (total == 0) return 0;
    final activas = _reservasPeriodo
        .where((r) => r.estado == 'confirmada' || r.estado == 'completada')
        .length;
    return activas / total * 100;
  }

  Map<String, int> get _distribucionCanchas {
    final mapa = <String, int>{};
    for (final r in _reservasPeriodo) {
      final nombre = r.nombreCancha ?? 'Sin nombre';
      mapa[nombre] = (mapa[nombre] ?? 0) + 1;
    }
    return mapa;
  }

  List<MapEntry<String, int>> get _horasMasSolicitadas {
    final mapa = <String, int>{};
    for (final r in _reservasPeriodo) {
      final key = '${r.horaInicio} – ${r.horaFin}';
      mapa[key] = (mapa[key] ?? 0) + 1;
    }
    final sorted = mapa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  double get _calificacionPromedio {
    final canchas = _filtroCancha != null
        ? _canchaCtrl.canchas.where((c) => c.nombre == _filtroCancha).toList()
        : _canchaCtrl.canchas.toList();
    final conCalif = canchas.where((c) => c.calificacionPromedio > 0).toList();
    if (conCalif.isEmpty) return 0.0;
    return conCalif.fold(0.0, (sum, c) => sum + c.calificacionPromedio) /
        conCalif.length;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _reservaCtrl.reservas.length;
      _canchaCtrl.canchas.length;
      if (_reservaCtrl.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: Colors.green[700]),
          ),
        );
      }
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltros(),
            _buildKpis(),
            _buildSeccion('Reservas por período', _buildBarChart()),
            _buildSeccion('Ingresos (COP)', _buildLineChart()),
            _buildSeccion('Distribución por cancha', _buildPieChart()),
            _buildSeccion('Horas más solicitadas', _buildHorasTable()),
          ],
        ),
      );
    });
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.green[100],
      padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Período
          Row(
            children: ['Día', 'Semana', 'Mes', 'Año'].map((p) {
              final sel = _periodo == p;
              return GestureDetector(
                onTap: () => setState(() { _periodo = p; _fechaRef = DateTime.now(); }),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? Colors.green[700] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Colors.green[700]! : Colors.grey[300]!),
                  ),
                  child: Text(p,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.grey[700])),
                ),
              );
            }).toList(),
          ),
          ...[
            SizedBox(height: 10),
            // Navegación de período
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _irAntes,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Icon(Icons.chevron_left, size: 20, color: Colors.green[800]),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  _etiquetaPeriodo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: _irAdelante,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Icon(Icons.chevron_right, size: 20, color: Colors.green[800]),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          // Cancha + Horario
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DropChip(
                  label: _filtroCancha ?? 'Tipo de cancha',
                  icon: Icons.sports_soccer_outlined,
                  activo: _filtroCancha != null,
                  onTap: () => _elegir(_canchas, _filtroCancha, (v) => setState(() => _filtroCancha = v)),
                ),
                SizedBox(width: 8),
                if (_filtroCancha != null)
                  GestureDetector(
                    onTap: () => setState(() { _filtroCancha = null; }),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red[200]!)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 14, color: Colors.red[700]),
                          SizedBox(width: 4),
                          Text('Limpiar', style: TextStyle(fontSize: 12, color: Colors.red[700])),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _elegir(List<String> opciones, String? actual, ValueChanged<String?> onChange) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          SizedBox(height: 12),
          if (actual != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: Text('Mostrar todos'),
              onTap: () { onChange(null); Navigator.pop(context); },
            ),
          ...opciones.map((o) => ListTile(
                leading: Icon(Icons.check_circle_outline,
                    color: actual == o ? Colors.green[700] : Colors.grey[400]),
                title: Text(o),
                trailing: actual == o ? Icon(Icons.check, color: Colors.green[700]) : null,
                onTap: () { onChange(o); Navigator.pop(context); },
              )),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKpis() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              _KpiCard(
                  titulo: 'Ingresos',
                  valor: '\$${_fmtK(_totalIngresos)}',
                  sub: _periodo,
                  icono: Icons.payments_outlined,
                  color: Colors.green[700]!),
              SizedBox(width: 10),
              _KpiCard(
                  titulo: 'Reservas',
                  valor: '${_totalReservas.toInt()}',
                  sub: _periodo,
                  icono: Icons.calendar_today_outlined,
                  color: Colors.teal[600]!),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _KpiCard(
                  titulo: 'Ocupación',
                  valor: '${_ocupacion.toInt()}%',
                  sub: 'Promedio',
                  icono: Icons.donut_large_outlined,
                  color: Colors.orange[700]!),
              SizedBox(width: 10),
              _KpiCard(
                  titulo: 'Calificación',
                  valor: _calificacionPromedio == 0
                      ? 'N/D'
                      : '${_calificacionPromedio.toStringAsFixed(1)} ★',
                  sub: 'Promedio',
                  icono: Icons.star_outline,
                  color: Colors.amber[700]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final datos = _datosReservas;
    final etiq = _etiquetas;
    final maxRaw = datos.isEmpty ? 0.0 : datos.reduce((a, b) => a > b ? a : b);
    final maxY = maxRaw == 0 ? 5.0 : maxRaw * 1.3;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, a) => BarTooltipItem(
                '${rod.toY.toInt()} reservas',
                TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= etiq.length) return SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(etiq[i], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
          ),
          barGroups: List.generate(datos.length, (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: datos[i],
                    color: Colors.green[600],
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final datos = _datosIngresos;
    final maxRaw = datos.isEmpty ? 0.0 : datos.reduce((a, b) => a > b ? a : b);
    final maxY = maxRaw == 0 ? 5000.0 : maxRaw * 1.25;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                    '\$${_fmtK(s.y)}',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  )).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= _etiquetas.length) return SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(_etiquetas[i], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(datos.length, (i) => FlSpot(i.toDouble(), datos[i])),
              isCurved: true,
              color: Colors.teal[600],
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (_, a, b, c) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.teal[600]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final distribucion = _distribucionCanchas;
    if (distribucion.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Sin datos para el período seleccionado',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ),
      );
    }
    final colores = [
      Colors.green[600]!,
      Colors.lightGreen[500]!,
      Colors.teal[400]!,
      Colors.orange[400]!,
      Colors.blue[400]!,
    ];
    final entradas = distribucion.entries.toList();
    final total = entradas.fold<int>(0, (s, e) => s + e.value);
    final secciones = entradas.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final pct = (e.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: colores[idx % colores.length],
        title: '$pct%',
        radius: 60,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(PieChartData(
            sections: secciones,
            centerSpaceRadius: 36,
            sectionsSpace: 3,
          )),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entradas.asMap().entries.map((entry) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _Leyenda(
                color: colores[entry.key % colores.length],
                texto: entry.value.key,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHorasTable() {
    final horas = _horasMasSolicitadas;
    if (horas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Sin reservas en el período seleccionado',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ),
      );
    }
    final maxVal = horas.first.value;
    return Column(
      children: horas.map((h) => Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(h.key,
                      style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxVal > 0 ? h.value / maxVal : 0,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green[600],
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text('${h.value}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[700])),
              ],
            ),
          )).toList(),
    );
  }

  Widget _buildSeccion(String titulo, Widget content) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  String _fmtK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB PERFIL
// ══════════════════════════════════════════════════════════════════════════════

class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return 'E';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      final canchaCtrl = Get.find<CanchaController>();
      final reservaCtrl = Get.find<ReservaController>();
      final empresaCtrl = Get.find<EmpresaController>();
      final usuario = auth.usuario.value;

      final nombre = usuario?.nombre ?? '';
      final nombreEmpresa = empresaCtrl.nombreEmpresa;
      final nit = empresaCtrl.nit;
      final email = usuario?.email ?? '';
      final telefono = usuario?.telefono ?? '';

      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Cabecera
            Container(
              color: Colors.green[100],
              padding: EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.green[200],
                        child: Text(_iniciales(nombreEmpresa.isNotEmpty ? nombreEmpresa : nombre),
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.greenAccent[400], shape: BoxShape.circle),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(nombreEmpresa.isNotEmpty ? nombreEmpresa : (nombre.isNotEmpty ? nombre : 'Mi Empresa'),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        empresaCtrl.estaVerificada ? Icons.verified : Icons.hourglass_top,
                        size: 15,
                        color: empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                      ),
                      SizedBox(width: 4),
                      Text(
                        empresaCtrl.estaVerificada ? 'Empresa verificada' : 'Empresa sin aprobar',
                        style: TextStyle(
                          fontSize: 13,
                          color: empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit_outlined, size: 16),
                    label: Text('Editar perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Información
            _SeccionPerfil(titulo: 'Información de la empresa', items: [
              _InfoItem(icono: Icons.business_outlined, label: 'Empresa', valor: nombreEmpresa.isNotEmpty ? nombreEmpresa : '—'),
              _InfoItem(icono: Icons.badge_outlined, label: 'NIT', valor: nit.isNotEmpty ? nit : '—'),
              _InfoItem(icono: Icons.person_outline, label: 'Responsable', valor: nombre.isNotEmpty ? nombre : '—'),
              _InfoItem(icono: Icons.phone_outlined, label: 'Teléfono', valor: telefono.isNotEmpty ? telefono : '—'),
              _InfoItem(icono: Icons.email_outlined, label: 'Correo', valor: email.isNotEmpty ? email : '—'),
            ]),

            SizedBox(height: 12),

            // Resumen de actividad
            _SeccionPerfil(titulo: 'Resumen de actividad', items: [
              _InfoItem(
                  icono: Icons.sports_soccer_outlined,
                  label: 'Canchas registradas',
                  valor: canchaCtrl.canchas.length.toString()),
              _InfoItem(
                  icono: Icons.calendar_today_outlined,
                  label: 'Total reservas',
                  valor: reservaCtrl.reservas.length.toString()),
              _InfoItem(
                  icono: Icons.check_circle_outline,
                  label: 'Reservas confirmadas',
                  valor: reservaCtrl.totalConfirmadas.toString()),
            ]),

            SizedBox(height: 12),

            // Opciones
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _OpcionItem(icono: Icons.lock_outline, label: 'Cambiar contraseña', onTap: () {}),
                  _OpcionItem(icono: Icons.notifications_outlined, label: 'Preferencias de notificación', onTap: () {}),
                  _OpcionItem(icono: Icons.help_outline, label: 'Ayuda y soporte', onTap: () {}),
                  _OpcionItem(icono: Icons.policy_outlined, label: 'Términos y condiciones', onTap: () {}),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => auth.logout(),
                      icon: Icon(Icons.logout, color: Colors.red[600]),
                      label: Text('Cerrar sesión',
                          style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS INTERNOS COMPARTIDOS
// ══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatCard({required this.label, required this.valor, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 22),
            SizedBox(height: 4),
            Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;

  const _MiniStat({required this.valor, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String sub;
  final IconData icono;
  final Color color;

  const _KpiCard(
      {required this.titulo,
      required this.valor,
      required this.sub,
      required this.icono,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icono, color: color, size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valor,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis),
                  Text(titulo, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool activo;
  final VoidCallback onTap;

  const _DropChip(
      {required this.label, required this.icon, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? Colors.green[700]! : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: activo ? Colors.white : Colors.grey[700]),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: activo ? Colors.white : Colors.grey[800])),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 14,
                color: activo ? Colors.white : Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8),
        Text(texto, style: TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}

class _SeccionPerfil extends StatelessWidget {
  final String titulo;
  final List<Widget> items;

  const _SeccionPerfil({required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(titulo,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ),
            Divider(height: 1),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoItem({required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icono, size: 20, color: Colors.green[700]),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(valor,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}

class _OpcionItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _OpcionItem({required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: ListTile(
        leading: Icon(icono, color: Colors.green[700], size: 22),
        title: Text(label, style: TextStyle(fontSize: 14)),
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
          padding: EdgeInsets.all(8),
          decoration:
              BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacion.mensaje, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 2),
            Text(_tiempoRelativo(notificacion.fecha),
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _CanchaEmpresaCard extends StatelessWidget {
  final Cancha cancha;
  final VoidCallback onToggleActiva;

  const _CanchaEmpresaCard({required this.cancha, required this.onToggleActiva});

  Color _colorFromDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol': return Colors.green;
      case 'tenis': return Colors.teal;
      case 'pádel': return Colors.cyan;
      case 'baloncesto': return Colors.orange;
      case 'voleibol': return Colors.blue;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFromDeporte(cancha.tipoDeporte);
    final bool activa = cancha.activa;
    final String cierreHora = cancha.horariosDisponibles.isNotEmpty
        ? cancha.horariosDisponibles.last
        : '--';

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: cancha.fotosUrl.isNotEmpty
                    ? _fotoCancha(cancha.fotosUrl.first, color, activa)
                    : _placeholderCancha(color, activa),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: activa ? Colors.green[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(activa ? 'Activa' : 'Inactiva',
                      style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(cancha.nombre,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_fmt(cancha.precioPorHora.toInt())}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green[700])),
                        Text('por hora', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(cancha.tipoDeporte,
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(width: 10),
                    CalificacionEstrellas(
                        rating: cancha.calificacionPromedio, size: 13),
                    SizedBox(width: 10),
                    Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[600]),
                    SizedBox(width: 3),
                    Text('Hasta $cierreHora',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrarCancha(cancha: cancha),
                          ),
                        ),
                        icon: Icon(Icons.edit_outlined, size: 16),
                        label: Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onToggleActiva,
                        icon: Icon(
                            activa ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            size: 16),
                        label: Text(activa ? 'Desactivar' : 'Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activa ? Colors.red[50] : Colors.green[50],
                          foregroundColor: activa ? Colors.red[700] : Colors.green[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
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

  Widget _fotoCancha(String url, Color color, bool activa) {
    final Widget img = url.startsWith('data:')
        ? () {
            try {
              final bytes = base64Decode(url.split(',').last);
              return Image.memory(bytes,
                  height: 130, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholderCancha(color, activa));
            } catch (_) {
              return _placeholderCancha(color, activa);
            }
          }()
        : Image.network(url,
            height: 130, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholderCancha(color, activa));

    return ColorFiltered(
      colorFilter: activa
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: img,
    );
  }

  Widget _placeholderCancha(Color color, bool activa) {
    return Container(
      height: 130,
      width: double.infinity,
      color: activa ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.sports_soccer_outlined, size: 60,
            color: activa ? color.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  String _fmt(int precio) {
    final s = precio.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
