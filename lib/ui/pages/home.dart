import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _authCtrl = Get.find<AuthController>();
  final _buscarCtrl = TextEditingController();

  static const _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  @override
  void initState() {
    super.initState();
    _canchaCtrl.cargarCanchas();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  void _mostrarSelectorDeporte() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Seleccionar deporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            if (_canchaCtrl.deporteFiltro.value != null) {
              return ListTile(
                leading: Icon(Icons.close, color: Colors.red[400]),
                title: const Text('Todos los deportes'),
                onTap: () {
                  _canchaCtrl.setDeporte(null);
                  Navigator.pop(context);
                },
              );
            }
            return const SizedBox.shrink();
          }),
          ..._deportes.map((d) => Obx(() => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _canchaCtrl.deporteFiltro.value == d
                    ? Icon(Icons.check, color: Colors.green[700])
                    : null,
                onTap: () {
                  _canchaCtrl.setDeporte(d);
                  Navigator.pop(context);
                },
              ))),
          const SizedBox(height: 16),
        ],
      ),
    );
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
            Icon(Icons.location_on_outlined, color: Colors.green[700], size: 20),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu Ubicación',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal)),
                Text('SportRent',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
          ],
        ),
        actions: [
          Obx(() => _authCtrl.isLoggedIn
              ? TextButton.icon(
                  onPressed: () {
                    final rol = _authCtrl.rol;
                    if (rol == 'cliente') {
                      Get.toNamed('/home-usuario');
                    } else if (rol == 'empresa') {
                      Get.toNamed('/home-empresa');
                    } else if (rol == 'admin') {
                      Get.toNamed('/home-admin');
                    }
                  },
                  icon: Icon(Icons.person_outline, color: Colors.green[800], size: 18),
                  label: Text(_authCtrl.nombre,
                      style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                )
              : TextButton.icon(
                  onPressed: () => Get.toNamed('/login'),
                  icon: Icon(Icons.login, color: Colors.green[800], size: 18),
                  label: Text('Iniciar sesión',
                      style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                )),
        ],
      ),
      body: Column(
        children: [
          _buildEncabezado(),
          Expanded(
            child: Obx(() {
              if (_canchaCtrl.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.green[700]));
              }
              final canchas = _canchaCtrl.canchasFiltradas;
              if (canchas.isEmpty) return _buildVacio();
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: canchas.length,
                itemBuilder: (_, i) => CanchaCard(cancha: canchas[i]),
              );
            }),
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
              onChanged: _canchaCtrl.setBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar canchas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: Obx(() => _canchaCtrl.busqueda.value.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(Icons.close, size: 18, color: Colors.grey[600]),
                        onPressed: () {
                          _buscarCtrl.clear();
                          _canchaCtrl.setBusqueda('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() => Row(
                  children: [
                    FiltroChip(
                      label: 'Cerca de mí',
                      icon: Icons.near_me_outlined,
                      activo: _canchaCtrl.soloCercanas.value,
                      onTap: _canchaCtrl.toggleCercanas,
                    ),
                    const SizedBox(width: 8),
                    _buildChipDeporte(),
                    const SizedBox(width: 8),
                    FiltroChip(
                      label: 'Restablecer',
                      icon: Icons.refresh,
                      activo: false,
                      esRestablecer: true,
                      onTap: () {
                        _buscarCtrl.clear();
                        _canchaCtrl.restablecerFiltros();
                      },
                    ),
                  ],
                )),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(
                  '${_canchaCtrl.canchasFiltradas.length} canchas disponibles',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChipDeporte() {
    final seleccionado = _canchaCtrl.deporteFiltro.value;
    return GestureDetector(
      onTap: _mostrarSelectorDeporte,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado != null ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado != null ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined,
                size: 16,
                color: seleccionado != null ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              seleccionado ?? 'Deporte',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: seleccionado != null ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16,
                color: seleccionado != null ? Colors.white : Colors.grey[600]),
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
          const SizedBox(height: 12),
          Text('No se encontraron canchas',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _buscarCtrl.clear();
              _canchaCtrl.restablecerFiltros();
            },
            child:
                Text('Restablecer filtros', style: TextStyle(color: Colors.green[700])),
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
    final Color bgColor =
        esRestablecer ? Colors.red[50]! : activo ? Colors.green[700]! : Colors.white;
    final Color textColor =
        esRestablecer ? Colors.red[700]! : activo ? Colors.white : Colors.grey[800]!;
    final Color borderColor =
        esRestablecer ? Colors.red[200]! : activo ? Colors.green[700]! : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class CanchaCard extends StatefulWidget {
  final Cancha cancha;
  final bool mostrarFavorito;
  final bool esFavorito;
  final VoidCallback? onToggleFavorito;

  const CanchaCard({
    super.key,
    required this.cancha,
    this.mostrarFavorito = false,
    this.esFavorito = false,
    this.onToggleFavorito,
  });

  static Color colorDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
      case 'futbol':
        return Colors.green;
      case 'baloncesto':
        return Colors.orange;
      case 'tenis':
        return Colors.teal;
      case 'pádel':
      case 'padel':
        return Colors.indigo;
      case 'voleibol':
        return Colors.blue;
      case 'béisbol':
      case 'beisbol':
        return Colors.brown;
      default:
        return Colors.green;
    }
  }

  static IconData iconoDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
      case 'futbol':
        return Icons.sports_soccer_outlined;
      case 'baloncesto':
        return Icons.sports_basketball_outlined;
      case 'tenis':
      case 'pádel':
      case 'padel':
        return Icons.sports_tennis_outlined;
      case 'voleibol':
        return Icons.sports_volleyball_outlined;
      default:
        return Icons.sports_outlined;
    }
  }

  @override
  State<CanchaCard> createState() => _CanchaCardState();
}

class _CanchaCardState extends State<CanchaCard> {
  int _paginaActual = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _formatPrecio(double precio) {
    final s = precio.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color = CanchaCard.colorDeporte(widget.cancha.tipoDeporte);
    final icono = CanchaCard.iconoDeporte(widget.cancha.tipoDeporte);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildImagenCarousel(color, icono),
              ),
              if (widget.mostrarFavorito && widget.onToggleFavorito != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: widget.onToggleFavorito,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        widget.esFavorito ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: widget.esFavorito ? Colors.red[400] : Colors.grey[500],
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
                        widget.cancha.nombre,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatPrecio(widget.cancha.precioPorHora)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        ),
                        Text('por hora',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.cancha.direccion,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CalificacionEstrellas(
                        rating: widget.cancha.calificacionPromedio, size: 14),
                    const SizedBox(width: 12),
                    Icon(Icons.sports_outlined, size: 14, color: color),
                    const SizedBox(width: 3),
                    Text(widget.cancha.tipoDeporte,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.toNamed('/disponibilidad', arguments: widget.cancha),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ver Disponibilidad',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenCarousel(Color color, IconData icono) {
    final fotos = widget.cancha.fotosUrl;
    if (fotos.isEmpty) return _placeholder(color, icono);

    return Stack(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (_, i) => _buildFotoCancha(fotos[i], color, icono),
          ),
        ),
        if (fotos.length > 1) ...[
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _paginaActual == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _paginaActual == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_paginaActual + 1}/${fotos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFotoCancha(String url, Color color, IconData icono) {
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(bytes,
            height: 160, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(color, icono));
      } catch (_) {
        return _placeholder(color, icono);
      }
    }
    return Image.network(url,
        height: 160, width: double.infinity, fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                height: 160,
                color: color.withValues(alpha: 0.1),
                child: Center(
                    child: CircularProgressIndicator(color: color, strokeWidth: 2))),
        errorBuilder: (_, _, _) => _placeholder(color, icono));
  }

  Widget _placeholder(Color color, IconData icono) {
    return Container(
      height: 160,
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      child: Center(
          child: Icon(icono, size: 72, color: color.withValues(alpha: 0.4))),
    );
  }
}

// ── Reutilizable en cualquier pantalla ────────────────────────────────────────
class CalificacionEstrellas extends StatelessWidget {
  final double rating;
  final double size;

  const CalificacionEstrellas({super.key, required this.rating, this.size = 13});

  @override
  Widget build(BuildContext context) {
    if (rating == 0.0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (_) =>
              Icon(Icons.star_border_rounded, size: size, color: Colors.grey[350])),
          const SizedBox(width: 4),
          Text('Nuevo',
              style: TextStyle(fontSize: size - 1, color: Colors.grey[500])),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (rating >= i + 1) {
            return Icon(Icons.star_rounded, size: size, color: Colors.amber[600]);
          }
          if (rating >= i + 0.5) {
            return Icon(Icons.star_half_rounded, size: size, color: Colors.amber[600]);
          }
          return Icon(Icons.star_border_rounded, size: size, color: Colors.grey[350]);
        }),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(
                fontSize: size - 1,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
      ],
    );
  }
}
