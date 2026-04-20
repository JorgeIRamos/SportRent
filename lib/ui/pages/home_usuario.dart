import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/ui/pages/home.dart';

class HomeUsuario extends StatefulWidget {
  final String nombreUsuario;

  const HomeUsuario({super.key, required this.nombreUsuario});

  @override
  State<HomeUsuario> createState() => _HomeUsuarioState();
}

class _HomeUsuarioState extends State<HomeUsuario> {
  final TextEditingController _buscarCtrl = TextEditingController();
  String? _deporteSeleccionado;
  bool _soloCercanas = false;
  bool _soloFavoritos = false;
  int _navIndex = 0;

  final List<String> _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  final List<Map<String, dynamic>> _canchas = [
    {
      'nombre': 'Cancha Fútbol 5 Premium',
      'empresa': 'Sports Center Pro',
      'deporte': 'Fútbol',
      'precio': 450000,
      'calificacion': 4.9,
      'numResenas': 156,
      'distancia': 0.8,
      'cierreHora': '23:00',
      'destacado': true,
      'favorito': false,
      'color': Colors.green,
    },
    {
      'nombre': 'Cancha de Tenis Central',
      'empresa': 'Club Deportivo Cesar',
      'deporte': 'Tenis',
      'precio': 320000,
      'calificacion': 4.7,
      'numResenas': 89,
      'distancia': 1.2,
      'cierreHora': '21:00',
      'destacado': false,
      'favorito': true,
      'color': Colors.teal,
    },
    {
      'nombre': 'Pádel Arena VIP',
      'empresa': 'Padel Club Norte',
      'deporte': 'Pádel',
      'precio': 280000,
      'calificacion': 4.5,
      'numResenas': 43,
      'distancia': 2.5,
      'cierreHora': '22:00',
      'destacado': false,
      'favorito': false,
      'color': Colors.indigo,
    },
    {
      'nombre': 'Cancha Baloncesto Techada',
      'empresa': 'Polideportivo Sur',
      'deporte': 'Baloncesto',
      'precio': 200000,
      'calificacion': 4.3,
      'numResenas': 71,
      'distancia': 3.1,
      'cierreHora': '20:00',
      'destacado': false,
      'favorito': false,
      'color': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get _canchasFiltradas {
    return _canchas.where((c) {
      if (_soloCercanas && (c['distancia'] as double) > 1.5) return false;
      if (_soloFavoritos && !(c['favorito'] as bool)) return false;
      if (_deporteSeleccionado != null && c['deporte'] != _deporteSeleccionado) return false;
      if (_buscarCtrl.text.isNotEmpty &&
          !(c['nombre'] as String).toLowerCase().contains(_buscarCtrl.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void _toggleFavorito(int indexEnLista) {
    final cancha = _canchasFiltradas[indexEnLista];
    final indexOriginal = _canchas.indexOf(cancha);
    setState(() => _canchas[indexOriginal]['favorito'] = !_canchas[indexOriginal]['favorito']);
  }

  void _restablecerFiltros() {
    setState(() {
      _soloCercanas = false;
      _soloFavoritos = false;
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
                  SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu Ubicación',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.normal)),
                      Text('Valledupar, Cesar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ],
              )
            : Text(_appBarTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _navIndex = 2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green[300],
                child: Text(
                  widget.nombreUsuario.isNotEmpty ? widget.nombreUsuario[0].toUpperCase() : 'U',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0: return _buildInicio();
      case 1: return _ReservasTab(nombreUsuario: widget.nombreUsuario);
      case 2: return _PerfilTab(nombreUsuario: widget.nombreUsuario);
      default: return _buildInicio();
    }
  }

  // ── INICIO ────────────────────────────────────────────────────────────────

  Widget _buildInicio() {
    final canchas = _canchasFiltradas;
    return Column(
      children: [
        _buildBienvenida(),
        _buildEncabezado(),
        Expanded(
          child: canchas.isEmpty
              ? _buildVacio()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 24),
                  itemCount: canchas.length,
                  itemBuilder: (ctx, i) => CanchaCard(
                    cancha: canchas[i],
                    mostrarFavorito: true,
                    onToggleFavorito: () => _toggleFavorito(i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBienvenida() {
    return Container(
      color: Colors.green[100],
      padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Text('¡Hola, ${widget.nombreUsuario.split(' ').first}! ',
              style: TextStyle(fontSize: 15, color: Colors.black87)),
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
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar canchas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _buscarCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                        onPressed: () => setState(() => _buscarCtrl.clear()),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                FiltroChip(
                  label: 'Cerca de mí',
                  icon: Icons.near_me_outlined,
                  activo: _soloCercanas,
                  onTap: () => setState(() => _soloCercanas = !_soloCercanas),
                ),
                SizedBox(width: 8),
                _buildChipDeporte(),
                SizedBox(width: 8),
                FiltroChip(
                  label: 'Favoritos',
                  icon: Icons.favorite_border,
                  activo: _soloFavoritos,
                  onTap: () => setState(() => _soloFavoritos = !_soloFavoritos),
                ),
                SizedBox(width: 8),
                FiltroChip(
                  label: 'Restablecer',
                  icon: Icons.refresh,
                  activo: false,
                  esRestablecer: true,
                  onTap: _restablecerFiltros,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              '${_canchasFiltradas.length} canchas cerca de ti',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
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
            color: _deporteSeleccionado != null ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined, size: 16,
                color: _deporteSeleccionado != null ? Colors.white : Colors.grey[700]),
            SizedBox(width: 6),
            Text(
              _deporteSeleccionado ?? 'Deporte',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _deporteSeleccionado != null ? Colors.white : Colors.grey[800],
              ),
            ),
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
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          SizedBox(height: 16),
          Text('Seleccionar deporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (_deporteSeleccionado != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: Text('Todos los deportes'),
              onTap: () {
                setState(() => _deporteSeleccionado = null);
                Navigator.pop(context);
              },
            ),
          ..._deportes.map((d) => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _deporteSeleccionado == d ? Icon(Icons.check, color: Colors.green[700]) : null,
                onTap: () {
                  setState(() => _deporteSeleccionado = d);
                  Navigator.pop(context);
                },
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
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text('No se encontraron canchas', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 8),
          TextButton(
            onPressed: _restablecerFiltros,
            child: Text('Restablecer filtros', style: TextStyle(color: Colors.green[700])),
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
            icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservas'),
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
  final String nombreUsuario;
  const _ReservasTab({required this.nombreUsuario});

  @override
  State<_ReservasTab> createState() => _ReservasTabState();
}

class _ReservasTabState extends State<_ReservasTab> {
  String _filtro = 'Todas';

  final List<Map<String, dynamic>> _reservas = [
    {
      'cancha': 'Cancha Fútbol 5 Premium',
      'empresa': 'Sports Center Pro',
      'fecha': 'Hoy',
      'hora': '15:00 – 16:00',
      'estado': 'Confirmada',
      'monto': 450000,
      'deporte': 'Fútbol',
      'color': Colors.green,
    },
    {
      'cancha': 'Cancha de Tenis Central',
      'empresa': 'Club Deportivo Cesar',
      'fecha': 'Mañana',
      'hora': '09:00 – 10:00',
      'estado': 'Pendiente',
      'monto': 320000,
      'deporte': 'Tenis',
      'color': Colors.teal,
    },
    {
      'cancha': 'Pádel Arena VIP',
      'empresa': 'Padel Club Norte',
      'fecha': '22 Abr',
      'hora': '17:00 – 18:00',
      'estado': 'Confirmada',
      'monto': 280000,
      'deporte': 'Pádel',
      'color': Colors.indigo,
    },
    {
      'cancha': 'Cancha Baloncesto Techada',
      'empresa': 'Polideportivo Sur',
      'fecha': '10 Abr',
      'hora': '10:00 – 11:00',
      'estado': 'Completada',
      'monto': 200000,
      'deporte': 'Baloncesto',
      'color': Colors.orange,
    },
    {
      'cancha': 'Cancha Fútbol 5 Premium',
      'empresa': 'Sports Center Pro',
      'fecha': '5 Abr',
      'hora': '18:00 – 19:00',
      'estado': 'Cancelada',
      'monto': 450000,
      'deporte': 'Fútbol',
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get _filtradas =>
      _filtro == 'Todas' ? _reservas : _reservas.where((r) => r['estado'] == _filtro).toList();

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Confirmada': return Colors.green[600]!;
      case 'Pendiente': return Colors.orange[600]!;
      case 'Cancelada': return Colors.red[400]!;
      case 'Completada': return Colors.blue[600]!;
      default: return Colors.grey;
    }
  }

  Color _bgEstado(String estado) {
    switch (estado) {
      case 'Confirmada': return Colors.green[50]!;
      case 'Pendiente': return Colors.orange[50]!;
      case 'Cancelada': return Colors.red[50]!;
      case 'Completada': return Colors.blue[50]!;
      default: return Colors.grey[100]!;
    }
  }

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'Confirmada': return Icons.check_circle_outline;
      case 'Pendiente': return Icons.hourglass_empty;
      case 'Cancelada': return Icons.cancel_outlined;
      case 'Completada': return Icons.sports_score;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;
    final proximas = _reservas.where((r) => r['estado'] == 'Confirmada' || r['estado'] == 'Pendiente').length;

    return Column(
      children: [
        // Resumen + filtros
        Container(
          color: Colors.green[100],
          padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MiniResumenCard(
                    valor: '$proximas',
                    label: 'Próximas',
                    color: Colors.green[700]!,
                    icono: Icons.upcoming_outlined,
                  ),
                  SizedBox(width: 10),
                  _MiniResumenCard(
                    valor: '${_reservas.where((r) => r['estado'] == 'Completada').length}',
                    label: 'Completadas',
                    color: Colors.blue[600]!,
                    icono: Icons.sports_score,
                  ),
                  SizedBox(width: 10),
                  _MiniResumenCard(
                    valor: '${_reservas.length}',
                    label: 'Total',
                    color: Colors.grey[700]!,
                    icono: Icons.calendar_month_outlined,
                  ),
                ],
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todas', 'Confirmada', 'Pendiente', 'Completada', 'Cancelada']
                      .map((f) {
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
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
          ),
        ),

        Expanded(
          child: lista.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
                      SizedBox(height: 12),
                      Text('No hay reservas en esta categoría',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 24),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final r = lista[i];
                    final Color c = r['color'] as Color;
                    final String estado = r['estado'] as String;
                    return Container(
                      margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        children: [
                          // Cabecera de la card
                          Container(
                            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.sports_soccer_outlined, color: c, size: 20),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r['cancha'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87),
                                          overflow: TextOverflow.ellipsis),
                                      Text(r['empresa'],
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: _bgEstado(estado),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_iconEstado(estado),
                                          size: 12, color: _colorEstado(estado)),
                                      SizedBox(width: 4),
                                      Text(estado,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _colorEstado(estado))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Detalles
                          Padding(
                            padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 14, color: Colors.grey[500]),
                                    SizedBox(width: 6),
                                    Text('${r['fecha']}  ·  ${r['hora']}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                    Spacer(),
                                    Text('\$${_fmt(r['monto'] as int)}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700])),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (estado == 'Confirmada' || estado == 'Pendiente') ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.cancel_outlined, size: 15),
                                          label: Text('Cancelar'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red[600],
                                            side: BorderSide(color: Colors.red[200]!),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.map_outlined, size: 15),
                                          label: Text('Ver cancha'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent[400],
                                            foregroundColor: Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (estado == 'Completada') ...[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.star_outline, size: 15),
                                          label: Text('Calificar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber[400],
                                            foregroundColor: Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.replay_outlined, size: 15),
                                          label: Text('Reservar de nuevo'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent[400],
                                            foregroundColor: Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (estado == 'Cancelada')
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.add_circle_outline, size: 15),
                                          label: Text('Nueva reserva'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent[400],
                                            foregroundColor: Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(vertical: 9),
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
// TAB PERFIL
// ══════════════════════════════════════════════════════════════════════════════

class _PerfilTab extends StatelessWidget {
  final String nombreUsuario;
  const _PerfilTab({required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          // Cabecera
          Container(
            width: double.infinity,
            color: Colors.green[100],
            padding: EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.green[300],
                      child: Text(
                        nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration:
                            BoxDecoration(color: Colors.greenAccent[400], shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(nombreUsuario,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 4),
                Text('usuario@email.com',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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

          // Actividad resumida
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ResumenItem(valor: '5', label: 'Reservas\ntotales', color: Colors.green[700]!),
                SizedBox(width: 10),
                _ResumenItem(valor: '2', label: 'Próximas\nreservas', color: Colors.teal[600]!),
                SizedBox(width: 10),
                _ResumenItem(valor: '4.8', label: 'Calificación\nrecibida', color: Colors.amber[700]!),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Información personal
          _SeccionPerfil(titulo: 'Información personal', items: const [
            _InfoItem(icono: Icons.person_outline, label: 'Nombre', valor: 'Jorge Ramos'),
            _InfoItem(icono: Icons.phone_outlined, label: 'Teléfono', valor: '+57 300 123 4567'),
            _InfoItem(icono: Icons.email_outlined, label: 'Correo', valor: 'jorge@email.com'),
            _InfoItem(icono: Icons.location_on_outlined, label: 'Ciudad', valor: 'Valledupar, Cesar'),
          ]),

          SizedBox(height: 12),

          // Opciones
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _OpcionItem(
                    icono: Icons.favorite_border,
                    label: 'Mis canchas favoritas',
                    badge: '2',
                    onTap: () {}),
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
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.find<AuthController>().logout(),
                    icon: Icon(Icons.logout, color: Colors.red[600]),
                    label: Text('Cerrar sesión',
                        style:
                            TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
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

          SizedBox(height: 16),
        ],
      ),
    );
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
      {required this.valor, required this.label, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            SizedBox(height: 4),
            Text(valor,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final String valor;
  final String label;
  final Color color;

  const _ResumenItem({required this.valor, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
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
  final String? badge;
  final VoidCallback onTap;

  const _OpcionItem(
      {required this.icono, required this.label, required this.onTap, this.badge});

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: EdgeInsets.only(right: 6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                child: Text(badge!,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700])),
              ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
