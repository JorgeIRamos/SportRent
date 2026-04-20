import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _buscarCtrl = TextEditingController();
  String? _deporteSeleccionado;
  bool _soloCercanas = false;

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
      'color': Colors.indigo,
    },
  ];

  List<Map<String, dynamic>> get _canchasFiltradas {
    return _canchas.where((c) {
      if (_soloCercanas && (c['distancia'] as double) > 1.5) return false;
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
      _soloCercanas = false;
      _deporteSeleccionado = null;
      _buscarCtrl.clear();
    });
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canchas = _canchasFiltradas;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.green[700], size: 20),
            SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu Ubicación', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.normal)),
                Text('Valledupar, Cesar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.toNamed('/login'),
            icon: Icon(Icons.login, color: Colors.green[800], size: 18),
            label: Text('Iniciar sesión', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEncabezado(),
          Expanded(
            child: canchas.isEmpty
                ? _buildVacio()
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 24),
                    itemCount: canchas.length,
                    itemBuilder: (ctx, i) => CanchaCard(cancha: canchas[i]),
                  ),
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
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
}

// ─── Widgets compartidos ────────────────────────────────────────────────────

class FiltroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool activo;
  final bool esRestablecer;
  final VoidCallback onTap;

  const FiltroChip({
    super.key,
    required this.label,
    required this.icon,
    required this.activo,
    required this.onTap,
    this.esRestablecer = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = esRestablecer ? Colors.red[50]! : activo ? Colors.green[700]! : Colors.white;
    final Color textColor = esRestablecer ? Colors.red[700]! : activo ? Colors.white : Colors.grey[800]!;
    final Color borderColor = esRestablecer ? Colors.red[200]! : activo ? Colors.green[700]! : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class CanchaCard extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback? onToggleFavorito;
  final bool mostrarFavorito;

  const CanchaCard({
    super.key,
    required this.cancha,
    this.onToggleFavorito,
    this.mostrarFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = cancha['color'] as Color;
    final bool esFavorito = (cancha['favorito'] as bool?) ?? false;
    final bool destacado = (cancha['destacado'] as bool?) ?? false;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: color.withValues(alpha: 0.15),
                  child: Center(
                    child: Icon(Icons.sports_soccer_outlined, size: 72, color: color.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              if (destacado)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber[600], borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Destacado', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              if (mostrarFavorito && onToggleFavorito != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onToggleFavorito,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                      ),
                      child: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: esFavorito ? Colors.red[400] : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cancha['nombre'],
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatPrecio(cancha['precio'] as int)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                        ),
                        Text('por hora', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(cancha['empresa'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    SizedBox(width: 3),
                    Text('${cancha['calificacion']} (${cancha['numResenas']})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    SizedBox(width: 12),
                    if (cancha['distancia'] != null) ...[
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.green[600]),
                      SizedBox(width: 3),
                      Text('A ${cancha['distancia']} km de ti',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      SizedBox(width: 12),
                    ],
                    Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 3),
                    Text('Hasta ${cancha['cierreHora']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Ver Disponibilidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrecio(int precio) {
    final s = precio.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
