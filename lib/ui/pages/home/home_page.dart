import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'home_widgets.dart';

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
