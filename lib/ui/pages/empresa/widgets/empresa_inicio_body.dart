import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';
import 'package:sport_rent/ui/pages/home_principal/widgets/home_widgets.dart';

class EmpresaInicioBody extends StatefulWidget {
  const EmpresaInicioBody({super.key});

  @override
  State<EmpresaInicioBody> createState() => _EmpresaInicioBodyState();
}

class _EmpresaInicioBodyState extends State<EmpresaInicioBody> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _reservaCtrl = Get.find<ReservaController>();
  final _empresaCtrl = Get.find<EmpresaController>();

  final TextEditingController _buscarCtrl = TextEditingController();
  String? _deporteSeleccionado;

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

  List<Cancha> get _canchasFiltradas {
    return _canchaCtrl.canchas.where((c) {
      if (_deporteSeleccionado != null && c.tipoDeporte != _deporteSeleccionado) {
        return false;
      }
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
  Widget build(BuildContext context) {
    return Obx(() {
      if (_canchaCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.green));
      }
      final canchas = _canchasFiltradas;
      final hoy = DateTime.now();
      final reservasHoy = _reservaCtrl.reservas
          .where((r) =>
              r.fecha.year == hoy.year &&
              r.fecha.month == hoy.month &&
              r.fecha.day == hoy.day)
          .length;
      return Column(
        children: [
          _buildResumen(canchas, reservasHoy),
          _buildEncabezado(canchas),
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
          StatCardEmpresa(
              label: 'Mis canchas',
              valor: '${canchas.length}',
              icono: Icons.sports_soccer,
              color: Colors.green[700]!),
          const SizedBox(width: 10),
          StatCardEmpresa(
              label: 'Activas',
              valor: '${canchas.where((c) => c.activa).length}',
              icono: Icons.check_circle_outline,
              color: Colors.teal[600]!),
          const SizedBox(width: 10),
          StatCardEmpresa(
              label: 'Reservas hoy',
              valor: '$reservasHoy',
              icono: Icons.calendar_today_outlined,
              color: Colors.orange[700]!),
        ],
      ),
    );
  }

  Widget _buildEncabezado(List<Cancha> canchas) {
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
                      child: Icon(Icons.hourglass_top,
                          color: Colors.orange[800], size: 18),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
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
            child: Text('${canchas.length} canchas encontradas',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
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
              color: _deporteSeleccionado != null
                  ? Colors.green[700]!
                  : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_outlined,
                size: 16,
                color: _deporteSeleccionado != null
                    ? Colors.white
                    : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              _deporteSeleccionado ?? 'Tipo de deporte',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _deporteSeleccionado != null
                      ? Colors.white
                      : Colors.grey[800]),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16,
                color: _deporteSeleccionado != null
                    ? Colors.white
                    : Colors.grey[600]),
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
          const Text('Filtrar por deporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_deporteSeleccionado != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: const Text('Todos los deportes'),
              onTap: () {
                setState(() => _deporteSeleccionado = null);
                Navigator.pop(context);
              },
            ),
          ..._deportes.map((d) => ListTile(
                leading: Icon(Icons.sports, color: Colors.green[700]),
                title: Text(d),
                trailing: _deporteSeleccionado == d
                    ? Icon(Icons.check, color: Colors.green[700])
                    : null,
                onTap: () {
                  setState(() => _deporteSeleccionado = d);
                  Navigator.pop(context);
                },
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
          Text('No se encontraron canchas',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
              onPressed: _restablecerFiltros,
              child: Text('Restablecer filtros',
                  style: TextStyle(color: Colors.green[700]))),
        ],
      ),
    );
  }
}
