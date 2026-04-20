import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
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
  int _notificacionesSinLeer = 3;

  final List<String> _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  final List<Map<String, dynamic>> _misCanchas = [
    {
      'nombre': 'Cancha Fútbol 5 Premium',
      'empresa': 'Mi Empresa',
      'deporte': 'Fútbol',
      'precio': 450000,
      'calificacion': 4.9,
      'numResenas': 156,
      'cierreHora': '23:00',
      'destacado': true,
      'activa': true,
      'reservasHoy': 3,
      'color': Colors.green,
    },
    {
      'nombre': 'Cancha Fútbol 11',
      'empresa': 'Mi Empresa',
      'deporte': 'Fútbol',
      'precio': 650000,
      'calificacion': 4.6,
      'numResenas': 42,
      'cierreHora': '22:00',
      'destacado': false,
      'activa': true,
      'reservasHoy': 1,
      'color': Colors.lightGreen,
    },
    {
      'nombre': 'Cancha de Tenis',
      'empresa': 'Mi Empresa',
      'deporte': 'Tenis',
      'precio': 280000,
      'calificacion': 4.3,
      'numResenas': 28,
      'cierreHora': '21:00',
      'destacado': false,
      'activa': false,
      'reservasHoy': 0,
      'color': Colors.teal,
    },
  ];

  List<Map<String, dynamic>> get _canchasFiltradas {
    return _misCanchas.where((c) {
      if (_deporteSeleccionado != null && c['deporte'] != _deporteSeleccionado) return false;
      if (_buscarCtrl.text.isNotEmpty &&
          !(c['nombre'] as String).toLowerCase().contains(_buscarCtrl.text.toLowerCase())) {
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
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    switch (_navIndex) {
      case 1: return 'Reservas';
      case 2: return 'Estadísticas';
      case 3: return 'Mi Perfil';
      default: return 'Mi Empresa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalReservasHoy = _misCanchas.fold<int>(0, (s, c) => s + (c['reservasHoy'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_appBarTitle,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            if (_navIndex == 0)
              Row(
                children: [
                  Icon(Icons.verified, size: 13, color: Colors.green[700]),
                  SizedBox(width: 3),
                  Text('Empresa verificada',
                      style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.normal)),
                ],
              ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () => _mostrarNotificaciones(context),
              ),
              if (_notificacionesSinLeer > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_notificacionesSinLeer',
                        style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(totalReservasHoy),
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RegistrarCancha())),
              backgroundColor: Colors.greenAccent[400],
              foregroundColor: Colors.black87,
              icon: Icon(Icons.add),
              label: Text('Añadir cancha', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody(int totalReservasHoy) {
    switch (_navIndex) {
      case 0: return _buildInicio(totalReservasHoy);
      case 1: return const _ReservasTab();
      case 2: return const _EstadisticasTab();
      case 3: return const _PerfilTab();
      default: return _buildInicio(totalReservasHoy);
    }
  }

  // ── INICIO ────────────────────────────────────────────────────────────────

  Widget _buildInicio(int totalReservasHoy) {
    final canchas = _canchasFiltradas;
    return Column(
      children: [
        _buildResumen(totalReservasHoy),
        _buildEncabezado(),
        Expanded(
          child: canchas.isEmpty
              ? _buildVacio()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 90),
                  itemCount: canchas.length,
                  itemBuilder: (ctx, i) => _CanchaEmpresaCard(
                    cancha: canchas[i],
                    onToggleActiva: () {
                      final orig = _misCanchas.indexOf(canchas[i]);
                      setState(() => _misCanchas[orig]['activa'] = !_misCanchas[orig]['activa']);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildResumen(int reservasHoy) {
    return Container(
      color: Colors.green[100],
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _StatCard(label: 'Mis canchas', valor: '${_misCanchas.length}',
              icono: Icons.sports_soccer, color: Colors.green[700]!),
          SizedBox(width: 10),
          _StatCard(
              label: 'Activas',
              valor: '${_misCanchas.where((c) => c['activa'] as bool).length}',
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
    setState(() => _notificacionesSinLeer = 0);
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
                ],
              ),
            ),
            Divider(height: 20),
            Expanded(
              child: ListView(
                controller: controller,
                children: const [
                  _NotifItem(icono: Icons.calendar_today, color: Colors.green,
                      titulo: 'Nueva reserva confirmada',
                      subtitulo: 'Carlos Pérez reservó Cancha Fútbol 5 · Hoy 15:00',
                      tiempo: 'Hace 5 min'),
                  _NotifItem(icono: Icons.star, color: Colors.amber,
                      titulo: 'Nueva calificación recibida',
                      subtitulo: 'Recibiste 5 estrellas en Cancha Fútbol 11',
                      tiempo: 'Hace 1 h'),
                  _NotifItem(icono: Icons.cancel_outlined, color: Colors.red,
                      titulo: 'Reserva cancelada',
                      subtitulo: 'Ana Torres canceló su reserva para mañana 10:00',
                      tiempo: 'Hace 2 h'),
                  _NotifItem(icono: Icons.payments_outlined, color: Colors.teal,
                      titulo: 'Pago recibido',
                      subtitulo: 'Se acreditaron \$450.000 por reserva #1023',
                      tiempo: 'Ayer'),
                  _NotifItem(icono: Icons.info_outline, color: Colors.blue,
                      titulo: 'Recuerda completar tu perfil',
                      subtitulo: 'Agrega el logo de tu empresa para mayor visibilidad',
                      tiempo: 'Hace 2 días'),
                ],
              ),
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
  String _filtro = 'Todas';

  final List<Map<String, dynamic>> _reservas = [
    {
      'cliente': 'Carlos Pérez',
      'cancha': 'Cancha Fútbol 5 Premium',
      'fecha': 'Hoy',
      'hora': '15:00 – 16:00',
      'estado': 'Confirmada',
      'monto': 450000,
      'color': Colors.green,
    },
    {
      'cliente': 'María López',
      'cancha': 'Cancha Fútbol 11',
      'fecha': 'Hoy',
      'hora': '17:00 – 18:00',
      'estado': 'Pendiente',
      'monto': 650000,
      'color': Colors.lightGreen,
    },
    {
      'cliente': 'Juan García',
      'cancha': 'Cancha de Tenis',
      'fecha': 'Mañana',
      'hora': '09:00 – 10:00',
      'estado': 'Confirmada',
      'monto': 280000,
      'color': Colors.teal,
    },
    {
      'cliente': 'Ana Torres',
      'cancha': 'Cancha Fútbol 5 Premium',
      'fecha': '22 Abr',
      'hora': '10:00 – 11:00',
      'estado': 'Cancelada',
      'monto': 450000,
      'color': Colors.green,
    },
    {
      'cliente': 'Luis Martínez',
      'cancha': 'Cancha Fútbol 11',
      'fecha': '23 Abr',
      'hora': '18:00 – 19:00',
      'estado': 'Confirmada',
      'monto': 650000,
      'color': Colors.lightGreen,
    },
    {
      'cliente': 'Sara Gómez',
      'cancha': 'Cancha de Tenis',
      'fecha': '24 Abr',
      'hora': '11:00 – 12:00',
      'estado': 'Pendiente',
      'monto': 280000,
      'color': Colors.teal,
    },
  ];

  List<Map<String, dynamic>> get _filtradas =>
      _filtro == 'Todas' ? _reservas : _reservas.where((r) => r['estado'] == _filtro).toList();

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Confirmada': return Colors.green[600]!;
      case 'Pendiente': return Colors.orange[600]!;
      case 'Cancelada': return Colors.red[400]!;
      default: return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'Confirmada': return Colors.green[50]!;
      case 'Pendiente': return Colors.orange[50]!;
      case 'Cancelada': return Colors.red[50]!;
      default: return Colors.grey[100]!;
    }
  }

  int get _totalConfirmadas => _reservas.where((r) => r['estado'] == 'Confirmada').length;
  int get _totalPendientes => _reservas.where((r) => r['estado'] == 'Pendiente').length;
  int get _totalCanceladas => _reservas.where((r) => r['estado'] == 'Cancelada').length;

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;
    return Column(
      children: [
        Container(
          color: Colors.green[100],
          padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  _MiniStat(valor: '$_totalConfirmadas', label: 'Confirm.', color: Colors.green[600]!),
                  SizedBox(width: 8),
                  _MiniStat(valor: '$_totalPendientes', label: 'Pendientes', color: Colors.orange[600]!),
                  SizedBox(width: 8),
                  _MiniStat(valor: '$_totalCanceladas', label: 'Canceladas', color: Colors.red[400]!),
                  SizedBox(width: 8),
                  _MiniStat(valor: '${_reservas.length}', label: 'Total', color: Colors.green[800]!),
                ],
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todas', 'Confirmada', 'Pendiente', 'Cancelada'].map((f) {
                    final sel = _filtro == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filtro = f),
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
        Expanded(
          child: lista.isEmpty
              ? Center(child: Text('No hay reservas', style: TextStyle(color: Colors.grey[500])))
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 16),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final r = lista[i];
                    final Color c = r['color'] as Color;
                    final String estado = r['estado'] as String;
                    return Container(
                      margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.sports_soccer_outlined, color: c),
                        ),
                        title: Text(r['cliente'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2),
                            Text(r['cancha'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                                SizedBox(width: 3),
                                Text('${r['fecha']}  ·  ${r['hora']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: _bgEstado(estado), borderRadius: BorderRadius.circular(8)),
                              child: Text(estado,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _colorEstado(estado))),
                            ),
                            SizedBox(height: 4),
                            Text('\$${_fmt(r['monto'] as int)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
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
  String? _filtroHorario;

  final List<String> _canchas = ['Cancha Fútbol 5', 'Cancha Fútbol 11', 'Cancha de Tenis'];
  final List<String> _horarios = ['Mañana (6–12h)', 'Tarde (12–18h)', 'Noche (18–24h)'];

  // Datos simulados por período
  List<double> get _datosReservas {
    switch (_periodo) {
      case 'Día': return [2, 3, 1, 4, 2, 3, 5, 2, 1, 3, 4, 2];
      case 'Semana': return [12, 18, 9, 22, 15, 28, 20];
      case 'Mes': return [85, 92, 78, 110];
      default: return [12, 18, 9, 22, 15, 28, 20];
    }
  }

  List<double> get _datosIngresos {
    switch (_periodo) {
      case 'Día': return [900, 1350, 450, 1800, 900, 1350, 2250, 900, 450, 1350, 1800, 900];
      case 'Semana': return [5400, 8100, 4050, 9900, 6750, 12600, 9000];
      case 'Mes': return [38250, 41400, 35100, 49500];
      default: return [5400, 8100, 4050, 9900, 6750, 12600, 9000];
    }
  }

  List<String> get _etiquetas {
    switch (_periodo) {
      case 'Día': return ['6h','7h','8h','9h','10h','11h','12h','13h','14h','15h','16h','17h'];
      case 'Semana': return ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
      case 'Mes': return ['Sem 1','Sem 2','Sem 3','Sem 4'];
      default: return ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    }
  }

  double get _totalIngresos => _datosIngresos.fold(0, (a, b) => a + b);
  double get _totalReservas => _datosReservas.fold(0, (a, b) => a + b);
  double get _ocupacion {
    switch (_periodo) {
      case 'Día': return 68;
      case 'Semana': return 74;
      case 'Mes': return 71;
      default: return 74;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: ['Día', 'Semana', 'Mes'].map((p) {
              final sel = _periodo == p;
              return GestureDetector(
                onTap: () => setState(() => _periodo = p),
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
                _DropChip(
                  label: _filtroHorario ?? 'Horario',
                  icon: Icons.schedule_outlined,
                  activo: _filtroHorario != null,
                  onTap: () => _elegir(_horarios, _filtroHorario, (v) => setState(() => _filtroHorario = v)),
                ),
                SizedBox(width: 8),
                if (_filtroCancha != null || _filtroHorario != null)
                  GestureDetector(
                    onTap: () => setState(() { _filtroCancha = null; _filtroHorario = null; }),
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
                  valor: '4.6 ★',
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
    final maxY = datos.reduce((a, b) => a > b ? a : b) * 1.3;

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
    final maxY = datos.reduce((a, b) => a > b ? a : b) * 1.25;

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
    final secciones = [
      PieChartSectionData(value: 48, color: Colors.green[600], title: '48%',
          radius: 60, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      PieChartSectionData(value: 34, color: Colors.lightGreen[500], title: '34%',
          radius: 60, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      PieChartSectionData(value: 18, color: Colors.teal[400], title: '18%',
          radius: 60, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ];

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
            children: [
              _Leyenda(color: Colors.green[600]!, texto: 'Cancha Fútbol 5'),
              SizedBox(height: 8),
              _Leyenda(color: Colors.lightGreen[500]!, texto: 'Cancha Fútbol 11'),
              SizedBox(height: 8),
              _Leyenda(color: Colors.teal[400]!, texto: 'Cancha de Tenis'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorasTable() {
    final horas = [
      {'hora': '18:00 – 19:00', 'reservas': 28, 'pct': 0.92},
      {'hora': '19:00 – 20:00', 'reservas': 26, 'pct': 0.85},
      {'hora': '17:00 – 18:00', 'reservas': 22, 'pct': 0.72},
      {'hora': '08:00 – 09:00', 'reservas': 18, 'pct': 0.59},
      {'hora': '20:00 – 21:00', 'reservas': 15, 'pct': 0.49},
    ];

    return Column(
      children: horas.map((h) => Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(h['hora'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: h['pct'] as double,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green[600],
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text('${h['reservas']}',
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

  @override
  Widget build(BuildContext context) {
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
                      child: Text('ME',
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
                Text('Mi Empresa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 15, color: Colors.green[700]),
                    SizedBox(width: 4),
                    Text('Empresa verificada',
                        style: TextStyle(fontSize: 13, color: Colors.green[700])),
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
          _SeccionPerfil(titulo: 'Información de la empresa', items: const [
            _InfoItem(icono: Icons.business_outlined, label: 'Nombre', valor: 'Mi Empresa S.A.S'),
            _InfoItem(icono: Icons.badge_outlined, label: 'NIT', valor: '900.123.456-7'),
            _InfoItem(icono: Icons.location_on_outlined, label: 'Ciudad', valor: 'Valledupar, Cesar'),
            _InfoItem(icono: Icons.phone_outlined, label: 'Teléfono', valor: '+57 301 234 5678'),
            _InfoItem(icono: Icons.email_outlined, label: 'Correo', valor: 'info@miempresa.com'),
          ]),

          SizedBox(height: 12),

          // Resumen
          _SeccionPerfil(titulo: 'Resumen de actividad', items: const [
            _InfoItem(icono: Icons.sports_soccer_outlined, label: 'Canchas registradas', valor: '3'),
            _InfoItem(icono: Icons.calendar_today_outlined, label: 'Total reservas', valor: '124'),
            _InfoItem(icono: Icons.star_outline, label: 'Calificación promedio', valor: '4.6 / 5.0'),
            _InfoItem(icono: Icons.payments_outlined, label: 'Ingresos este mes', valor: '\$4.950.000'),
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
                    onPressed: () => Get.find<AuthController>().logout(),
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

class _NotifItem extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final String tiempo;

  const _NotifItem(
      {required this.icono,
      required this.color,
      required this.titulo,
      required this.subtitulo,
      required this.tiempo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration:
            BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icono, color: color, size: 20),
      ),
      title: Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitulo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 2),
          Text(tiempo, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _CanchaEmpresaCard extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onToggleActiva;

  const _CanchaEmpresaCard({required this.cancha, required this.onToggleActiva});

  @override
  Widget build(BuildContext context) {
    final Color color = cancha['color'] as Color;
    final bool activa = cancha['activa'] as bool;
    final int reservasHoy = cancha['reservasHoy'] as int;

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
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: activa ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(Icons.sports_soccer_outlined, size: 60,
                        color: activa ? color.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.3)),
                  ),
                ),
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
              if (reservasHoy > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration:
                        BoxDecoration(color: Colors.orange[600], borderRadius: BorderRadius.circular(20)),
                    child: Text('$reservasHoy reserva${reservasHoy > 1 ? 's' : ''} hoy',
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
                      child: Text(cancha['nombre'],
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_fmt(cancha['precio'] as int)}',
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
                      child: Text(cancha['deporte'],
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.star, size: 13, color: Colors.amber[600]),
                    SizedBox(width: 3),
                    Text('${cancha['calificacion']} (${cancha['numResenas']})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    SizedBox(width: 10),
                    Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[600]),
                    SizedBox(width: 3),
                    Text('Hasta ${cancha['cierreHora']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
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
