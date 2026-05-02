import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/favorito_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/home_principal/widgets/home_widgets.dart';

class UsuarioInicioBody extends StatefulWidget {
  final String nombreUsuario;

  const UsuarioInicioBody({super.key, required this.nombreUsuario});

  @override
  State<UsuarioInicioBody> createState() => _UsuarioInicioBodyState();
}

class _UsuarioInicioBodyState extends State<UsuarioInicioBody> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _favoritoCtrl = Get.find<FavoritoController>();
  final _authCtrl = Get.find<AuthController>();

  final _buscarCtrl = TextEditingController();
  bool _soloFavoritos = false;

  static const _deportes = [
    'Fútbol',
    'Baloncesto',
    'Tenis',
    'Pádel',
    'Voleibol',
    'Béisbol',
  ];

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  List<Cancha> get _listaFinal {
    final base = _canchaCtrl.canchasFiltradas;
    if (_soloFavoritos) {
      return base.where((c) => _favoritoCtrl.esFavorito(c.id)).toList();
    }
    return base;
  }

  void _restablecerFiltros() {
    setState(() {
      _soloFavoritos = false;
      _buscarCtrl.clear();
    });
    _canchaCtrl.restablecerFiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBienvenida(),
        _buildEncabezado(),
        Expanded(
          child: Obx(() {
            if (_canchaCtrl.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]));
            }
            final canchas = _listaFinal;
            if (canchas.isEmpty) return _buildVacio();
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: canchas.length,
              itemBuilder: (_, i) {
                final cancha = canchas[i];
                return Obx(() => CanchaCard(
                      cancha: cancha,
                      mostrarFavorito: true,
                      esFavorito: _favoritoCtrl.esFavorito(cancha.id),
                      distanciaKm: _canchaCtrl.distanciaKm(cancha),
                      onToggleFavorito: () {
                        final uid = _authCtrl.usuario.value?.id ?? '';
                        if (uid.isNotEmpty) {
                          _favoritoCtrl.toggleFavorito(uid, cancha.id);
                        }
                      },
                    ));
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBienvenida() {
    return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Text('¡Hola, ${widget.nombreUsuario.split(' ').first}! ',
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
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
              onChanged: _canchaCtrl.setBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar canchas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: Obx(() => _canchaCtrl.busqueda.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
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
                      icon: _canchaCtrl.cargandoUbicacion.value
                          ? Icons.location_searching
                          : Icons.near_me_outlined,
                      activo: _canchaCtrl.soloCercanas.value,
                      onTap: () => _canchaCtrl.toggleCercanas(),
                    ),
                    const SizedBox(width: 8),
                    _buildChipDeporte(),
                    const SizedBox(width: 8),
                    FiltroChip(
                      label: 'Favoritos',
                      icon: Icons.favorite_border,
                      activo: _soloFavoritos,
                      onTap: () =>
                          setState(() => _soloFavoritos = !_soloFavoritos),
                    ),
                    const SizedBox(width: 8),
                    FiltroChip(
                      label: 'Restablecer',
                      icon: Icons.refresh,
                      activo: false,
                      esRestablecer: true,
                      onTap: _restablecerFiltros,
                    ),
                  ],
                )),
          ),
          Obx(() {
            final total = _listaFinal.length;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                '$total canchas disponibles',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            );
          }),
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Seleccionar deporte',
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
            onPressed: _restablecerFiltros,
            child: Text('Restablecer filtros',
                style: TextStyle(color: Colors.green[700])),
          ),
        ],
      ),
    );
  }
}
