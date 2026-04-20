import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _navIndex = 0;
  String? _filtroDeporte;
  final TextEditingController _buscarCtrl = TextEditingController();

  final List<String> _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  final List<Map<String, dynamic>> _todasLasCanchas = [
    {
      'nombre': 'Cancha Fútbol 5 Premium',
      'empresa': 'Sports Center Pro',
      'deporte': 'Fútbol',
      'precio': 450000,
      'calificacion': 4.9,
      'numResenas': 156,
      'activa': true,
      'verificada': true,
      'color': Colors.green,
    },
    {
      'nombre': 'Cancha de Tenis Central',
      'empresa': 'Club Deportivo Cesar',
      'deporte': 'Tenis',
      'precio': 320000,
      'calificacion': 4.7,
      'numResenas': 89,
      'activa': true,
      'verificada': true,
      'color': Colors.teal,
    },
    {
      'nombre': 'Pádel Arena VIP',
      'empresa': 'Padel Club Norte',
      'deporte': 'Pádel',
      'precio': 280000,
      'calificacion': 4.5,
      'numResenas': 43,
      'activa': false,
      'verificada': false,
      'color': Colors.indigo,
    },
    {
      'nombre': 'Cancha Baloncesto Techada',
      'empresa': 'Polideportivo Sur',
      'deporte': 'Baloncesto',
      'precio': 200000,
      'calificacion': 4.3,
      'numResenas': 71,
      'activa': true,
      'verificada': false,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _empresasPendientes = [
    {'nombre': 'Padel Club Norte', 'nit': '900123456-1', 'fecha': '18 Abr 2026'},
    {'nombre': 'Polideportivo Sur', 'nit': '800987654-2', 'fecha': '19 Abr 2026'},
  ];

  List<Map<String, dynamic>> get _canchasFiltradas {
    return _todasLasCanchas.where((c) {
      if (_filtroDeporte != null && c['deporte'] != _filtroDeporte) return false;
      if (_buscarCtrl.text.isNotEmpty &&
          !(c['nombre'] as String).toLowerCase().contains(_buscarCtrl.text.toLowerCase()) &&
          !(c['empresa'] as String).toLowerCase().contains(_buscarCtrl.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
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
            Icon(Icons.admin_panel_settings_outlined, color: Colors.green[800], size: 22),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Panel Admin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('SportRent', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          if (_empresasPendientes.isNotEmpty)
            Stack(
              children: [
                IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${_empresasPendientes.length}',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
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
        return _buildInicio();
      case 1:
        return _buildCanchas();
      case 2:
        return _buildEmpresas();
      default:
        return _buildInicio();
    }
  }

  Widget _buildInicio() {
    final totalCanchas = _todasLasCanchas.length;
    final activas = _todasLasCanchas.where((c) => c['activa'] as bool).length;
    final pendientesVerif = _todasLasCanchas.where((c) => !(c['verificada'] as bool)).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen general', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          Row(
            children: [
              _AdminStatCard(label: 'Total canchas', valor: '$totalCanchas', icono: Icons.sports_soccer, color: Colors.green[700]!),
              SizedBox(width: 10),
              _AdminStatCard(label: 'Activas', valor: '$activas', icono: Icons.check_circle_outline, color: Colors.teal[600]!),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _AdminStatCard(label: 'Empresas', valor: '${_empresasPendientes.length + 2}', icono: Icons.business_outlined, color: Colors.blue[700]!),
              SizedBox(width: 10),
              _AdminStatCard(label: 'Sin verificar', valor: '$pendientesVerif', icono: Icons.pending_outlined, color: Colors.orange[700]!),
            ],
          ),
          if (_empresasPendientes.isNotEmpty) ...[
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.orange[700], size: 20),
                SizedBox(width: 8),
                Text('Empresas pendientes de verificación',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 10),
            ..._empresasPendientes.map((e) => _EmpresaPendienteCard(
                  empresa: e,
                  onAprobar: () {
                    setState(() => _empresasPendientes.remove(e));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${e['nombre']} verificada correctamente'), backgroundColor: Colors.green),
                    );
                  },
                  onRechazar: () {
                    setState(() => _empresasPendientes.remove(e));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${e['nombre']} rechazada'), backgroundColor: Colors.red),
                    );
                  },
                )),
          ],
          SizedBox(height: 24),
          Text('Canchas recientes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ..._todasLasCanchas.take(2).map((c) => _CanchaAdminRow(
                cancha: c,
                onToggle: () {
                  final i = _todasLasCanchas.indexOf(c);
                  setState(() => _todasLasCanchas[i]['activa'] = !_todasLasCanchas[i]['activa']);
                },
              )),
          TextButton(
            onPressed: () => setState(() => _navIndex = 1),
            child: Text('Ver todas las canchas', style: TextStyle(color: Colors.green[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildCanchas() {
    final canchas = _canchasFiltradas;

    return Column(
      children: [
        Container(
          color: Colors.green[100],
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: _buscarCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar cancha o empresa...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _buscarCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _buscarCtrl.clear()),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._deportes.map((d) => Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(d),
                            selected: _filtroDeporte == d,
                            selectedColor: Colors.green[700],
                            labelStyle: TextStyle(
                              color: _filtroDeporte == d ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                            onSelected: (_) => setState(() => _filtroDeporte = _filtroDeporte == d ? null : d),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${canchas.length} canchas', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ),
        Expanded(
          child: canchas.isEmpty
              ? Center(child: Text('No se encontraron canchas', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 16),
                  itemCount: canchas.length,
                  itemBuilder: (ctx, i) => _CanchaAdminRow(
                    cancha: canchas[i],
                    onToggle: () {
                      final original = _todasLasCanchas.indexOf(canchas[i]);
                      setState(() => _todasLasCanchas[original]['activa'] = !_todasLasCanchas[original]['activa']);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmpresas() {
    final todasEmpresas = [
      {'nombre': 'Sports Center Pro', 'nit': '700111222-3', 'canchas': 2, 'verificada': true},
      {'nombre': 'Club Deportivo Cesar', 'nit': '600333444-5', 'canchas': 1, 'verificada': true},
      ..._empresasPendientes.map((e) => {
            'nombre': e['nombre'],
            'nit': e['nit'],
            'canchas': 1,
            'verificada': false,
          }),
    ];

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text('Todas las empresas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ...todasEmpresas.map((e) => Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (e['verificada'] as bool) ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business,
                        color: (e['verificada'] as bool) ? Colors.green[700] : Colors.orange[700]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['nombre'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('NIT: ${e['nit']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('${e['canchas']} cancha${(e['canchas'] as int) > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (e['verificada'] as bool) ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (e['verificada'] as bool) ? 'Verificada' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (e['verificada'] as bool) ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Resumen'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_soccer_outlined), activeIcon: Icon(Icons.sports_soccer), label: 'Canchas'),
        BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Empresas'),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _AdminStatCard({required this.label, required this.valor, required this.icono, required this.color});

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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icono, color: color, size: 22),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmpresaPendienteCard extends StatelessWidget {
  final Map<String, dynamic> empresa;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _EmpresaPendienteCard({required this.empresa, required this.onAprobar, required this.onRechazar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: Colors.orange[700], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(empresa['nombre'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                child: Text('Pendiente', style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text('NIT: ${empresa['nit']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text('Solicitud: ${empresa['fecha']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAprobar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[400],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Aprobar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRechazar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CanchaAdminRow extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onToggle;

  const _CanchaAdminRow({required this.cancha, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final Color color = cancha['color'] as Color;
    final bool activa = cancha['activa'] as bool;
    final bool verificada = cancha['verificada'] as bool;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.sports_soccer_outlined, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cancha['nombre'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(cancha['empresa'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(cancha['deporte'], style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(width: 6),
                    if (!verificada)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6)),
                        child: Text('Sin verificar', style: TextStyle(fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: activa,
            onChanged: (_) => onToggle(),
            activeThumbColor: Colors.green[700],
          ),
        ],
      ),
    );
  }
}
