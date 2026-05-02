import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/admin/widgets/home_admin_widgets.dart';

class AdminCanchasBody extends StatefulWidget {
  const AdminCanchasBody({super.key});

  @override
  State<AdminCanchasBody> createState() => _AdminCanchasBodyState();
}

class _AdminCanchasBodyState extends State<AdminCanchasBody> {
  final _canchaCtrl = Get.find<CanchaController>();

  final _buscarCtrl = TextEditingController();
  String _buscar = '';
  String? _filtroDeporte;

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
      if (_filtroDeporte != null && c.tipoDeporte != _filtroDeporte) {
        return false;
      }
      if (_buscar.isNotEmpty &&
          !c.nombre.toLowerCase().contains(_buscar.toLowerCase()) &&
          !c.direccion.toLowerCase().contains(_buscar.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.green[100],
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: _buscarCtrl,
                onChanged: (v) => setState(() => _buscar = v),
                decoration: InputDecoration(
                  hintText: 'Buscar cancha o dirección...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _buscar.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _buscarCtrl.clear();
                            setState(() => _buscar = '');
                          },
                        )
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
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _deportes
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(d),
                              selected: _filtroDeporte == d,
                              selectedColor: Colors.green[700],
                              labelStyle: TextStyle(
                                color: _filtroDeporte == d
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12,
                              ),
                              onSelected: (_) => setState(() =>
                                  _filtroDeporte =
                                      _filtroDeporte == d ? null : d),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final canchas = _canchasFiltradas;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${canchas.length} canchas',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          );
        }),
        Expanded(
          child: Obx(() {
            final canchas = _canchasFiltradas;
            if (_canchaCtrl.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]));
            }
            if (canchas.isEmpty) {
              return Center(
                  child: Text('No se encontraron canchas',
                      style: TextStyle(color: Colors.grey[600])));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: canchas.length,
              itemBuilder: (_, i) => CanchaAdminRow(
                cancha: canchas[i],
                onToggle: () => _canchaCtrl.toggleActiva(canchas[i].id),
              ),
            );
          }),
        ),
      ],
    );
  }
}
