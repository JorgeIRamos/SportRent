import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/widgets/custom_buttom.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';
import 'package:sport_rent/ui/widgets/custom_timepicker.dart';

class RegistrarCancha extends StatefulWidget {
  const RegistrarCancha({super.key});

  @override
  State<RegistrarCancha> createState() => _RegistrarCanchaState();
}

class _RegistrarCanchaState extends State<RegistrarCancha> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _authCtrl = Get.find<AuthController>();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _deporteCtrl = TextEditingController();

  final List<String> _fotosAgregadas = [];
  final List<Map<String, String>> _horarios = [];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _direccionCtrl.dispose();
    _deporteCtrl.dispose();
    super.dispose();
  }

  void _agregarHorario() {
    setState(() => _horarios.add({'dia': 'Lunes', 'inicio': '08:00', 'fin': '22:00'}));
  }

  void _eliminarHorario(int index) {
    setState(() => _horarios.removeAt(index));
  }

  void _agregarFotoSimulada() {
    setState(() => _fotosAgregadas.add('foto_${_fotosAgregadas.length + 1}.jpg'));
  }

  void _eliminarFoto(int index) {
    setState(() => _fotosAgregadas.removeAt(index));
  }

  Future<void> _registrar() async {
    if (_nombreCtrl.text.isEmpty ||
        _precioCtrl.text.isEmpty ||
        _direccionCtrl.text.isEmpty ||
        _deporteCtrl.text.isEmpty) {
      Get.snackbar(
        'Campos incompletos',
        'Nombre, precio, dirección y deporte son obligatorios',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        icon: Icon(Icons.warning_amber_outlined, color: Colors.red[400]),
      );
      return;
    }

    final precio = double.tryParse(_precioCtrl.text.replaceAll('.', '').replaceAll(',', '.'));
    if (precio == null) {
      Get.snackbar('Precio inválido', 'Ingresa un valor numérico',
          backgroundColor: Colors.red[50], colorText: Colors.red[700]);
      return;
    }

    final cancha = Cancha(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      empresaId: _authCtrl.empresaId.isNotEmpty ? _authCtrl.empresaId : 'emp_demo',
      nombre: _nombreCtrl.text.trim(),
      tipoDeporte: _deporteCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      precioPorHora: precio,
      direccion: _direccionCtrl.text.trim(),
      latitud: 0,
      longitud: 0,
      horariosDisponibles: _horarios
          .map((h) => '${h['dia']} ${h['inicio']}-${h['fin']}')
          .toList(),
    );

    final ok = await _canchaCtrl.registrarCancha(cancha);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SportRent', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Text('Registrar Cancha',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text('Completa la información de tu cancha deportiva',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
            SizedBox(height: 20),

            _seccionTitulo('Información básica'),
            customField('Nombre de la cancha', Icons.sports_soccer_outlined,
                controller: _nombreCtrl),
            customField('Descripción', Icons.description_outlined,
                controller: _descripcionCtrl),
            customField('Precio por hora (COP)', Icons.attach_money_outlined,
                controller: _precioCtrl, keyboardType: TextInputType.number),
            customField('Dirección', Icons.location_on_outlined,
                controller: _direccionCtrl),

            _seccionTitulo('Tipo de deporte'),
            customField('Ej: Fútbol, Baloncesto, Tenis...', Icons.sports_outlined,
                controller: _deporteCtrl),

            _seccionTitulo('Fotos de la cancha'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  if (_fotosAgregadas.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fotosAgregadas.length,
                        separatorBuilder: (_, i) => SizedBox(width: 10),
                        itemBuilder: (context, i) => Stack(
                          children: [
                            Container(
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, color: Colors.green[700], size: 32),
                                  SizedBox(height: 4),
                                  Text('Foto ${i + 1}', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _eliminarFoto(i),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red[400], shape: BoxShape.circle),
                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _agregarFotoSimulada,
                    icon: Icon(Icons.add_photo_alternate_outlined),
                    label: Text('Agregar foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            _seccionTitulo('Horarios disponibles'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  ..._horarios.asMap().entries.map((entry) {
                    int i = entry.key;
                    return _HorarioItem(
                      index: i,
                      horario: entry.value,
                      onEliminar: () => _eliminarHorario(i),
                      onCambio: (nuevo) => setState(() => _horarios[i] = nuevo),
                    );
                  }),
                  SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _agregarHorario,
                    icon: Icon(Icons.add_alarm_outlined),
                    label: Text('Agregar horario'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            Obx(() => customButtom(
                  'Registrar Cancha',
                  isLoading: _canchaCtrl.isLoading.value,
                  onPressed: _registrar,
                )),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 4),
      child: Text(titulo,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}

class _HorarioItem extends StatelessWidget {
  final int index;
  final Map<String, String> horario;
  final VoidCallback onEliminar;
  final ValueChanged<Map<String, String>> onCambio;

  const _HorarioItem({
    required this.index,
    required this.horario,
    required this.onEliminar,
    required this.onCambio,
  });

  static const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButton<String>(
              value: horario['dia'],
              isExpanded: true,
              underline: SizedBox(),
              items: _dias
                  .map((d) => DropdownMenuItem(
                      value: d, child: Text(d, style: TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (val) => onCambio({...horario, 'dia': val!}),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(
                context, 'Inicio', horario['inicio']!, (v) => onCambio({...horario, 'inicio': v})),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(
                context, 'Fin', horario['fin']!, (v) => onCambio({...horario, 'fin': v})),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[300], size: 20),
            onPressed: onEliminar,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
