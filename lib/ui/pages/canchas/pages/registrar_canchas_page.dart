import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/componentes/custom_button.dart';
import 'package:sport_rent/ui/componentes/custom_text_field.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/map_location_picker.dart';
import 'package:sport_rent/ui/pages/canchas/widgets/registrar_canchas_widgets.dart';

class RegistrarCancha extends StatefulWidget {
  final Cancha? cancha;
  const RegistrarCancha({super.key, this.cancha});

  @override
  State<RegistrarCancha> createState() => _RegistrarCanchaState();
}

class _RegistrarCanchaState extends State<RegistrarCancha> {
  final _canchaCtrl = Get.find<CanchaController>();
  final _authCtrl = Get.find<AuthController>();
  final _empresaCtrl = Get.find<EmpresaController>();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  LatLng? _selectedLatLng;
  String? _deporteSeleccionado;

  static const _deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Voleibol', 'Béisbol'];

  final List<String> _fotosUrls = [];
  final List<bool> _subiendo = [];
  final List<Map<String, String>> _horarios = [];

  bool get _modoEdicion => widget.cancha != null;

  @override
  void initState() {
    super.initState();
    if (_modoEdicion) {
      final c = widget.cancha!;
      _nombreCtrl.text = c.nombre;
      _descripcionCtrl.text = c.descripcion;
      _precioCtrl.text = c.precioPorHora.toInt().toString();
      _direccionCtrl.text = c.direccion;
      _deporteSeleccionado = c.tipoDeporte;
      _fotosUrls.addAll(c.fotosUrl);
      _subiendo.addAll(List.filled(c.fotosUrl.length, false));
      _horarios.addAll(c.horariosDisponibles.map(_parseHorario));
      if (c.latitud != 0 || c.longitud != 0) {
        _selectedLatLng = LatLng(c.latitud, c.longitud);
      }
    }
  }

  Map<String, String> _parseHorario(String s) {
    final idx = s.indexOf(' ');
    if (idx == -1) return {'dia': 'Lunes', 'inicio': '08:00', 'fin': '22:00'};
    final dia = s.substring(0, idx);
    final tiempos = s.substring(idx + 1).split('-');
    return {
      'dia': dia,
      'inicio': tiempos.isNotEmpty ? tiempos[0] : '08:00',
      'fin': tiempos.length > 1 ? tiempos[1] : '22:00',
    };
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _agregarHorario() {
    setState(() => _horarios.add({'dia': 'Lunes', 'inicio': '08:00', 'fin': '22:00'}));
  }

  void _eliminarHorario(int index) {
    setState(() => _horarios.removeAt(index));
  }

  Future<void> _abrirMapaPicker() async {
    final result = await Navigator.push<MapLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(initialPosition: _selectedLatLng),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result.latLng;
        _direccionCtrl.text = result.direccion;
      });
    }
  }

  Future<void> _agregarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
      maxWidth: 800,
      maxHeight: 600,
    );
    if (picked == null) return;

    final index = _fotosUrls.length;
    setState(() {
      _fotosUrls.add('');
      _subiendo.add(true);
    });

    try {
      final bytes = await picked.readAsBytes();
      final b64 = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$b64';
      setState(() {
        _fotosUrls[index] = dataUrl;
        _subiendo[index] = false;
      });
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
      setState(() {
        _fotosUrls.removeAt(index);
        _subiendo.removeAt(index);
      });
      Get.snackbar('Error', 'No se pudo procesar la imagen',
          backgroundColor: Colors.red[50], colorText: Colors.red[700]);
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotosUrls.removeAt(index);
      _subiendo.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.isEmpty ||
        _precioCtrl.text.isEmpty ||
        _direccionCtrl.text.isEmpty ||
        _deporteSeleccionado == null) {
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

    final fotos = List<String>.from(_fotosUrls.where((u) => u.isNotEmpty));
    final horarios = _horarios.map((h) => '${h['dia']} ${h['inicio']}-${h['fin']}').toList();

    final latitud = _selectedLatLng?.latitude ?? 0.0;
    final longitud = _selectedLatLng?.longitude ?? 0.0;

    if (_modoEdicion) {
      final original = widget.cancha!;
      final actualizada = Cancha(
        id: original.id,
        empresaId: original.empresaId,
        nombre: _nombreCtrl.text.trim(),
        tipoDeporte: _deporteSeleccionado!,
        descripcion: _descripcionCtrl.text.trim(),
        precioPorHora: precio,
        direccion: _direccionCtrl.text.trim(),
        latitud: latitud != 0 ? latitud : original.latitud,
        longitud: longitud != 0 ? longitud : original.longitud,
        fotosUrl: fotos,
        horariosDisponibles: horarios,
        calificacionPromedio: original.calificacionPromedio,
        activa: original.activa,
      );
      final ok = await _canchaCtrl.actualizarCancha(actualizada);
      if (ok) Get.back();
    } else {
      final nueva = Cancha(
        id: '',
        empresaId: _authCtrl.empresaId.isNotEmpty ? _authCtrl.empresaId : 'emp_demo',
        nombre: _nombreCtrl.text.trim(),
        tipoDeporte: _deporteSeleccionado!,
        descripcion: _descripcionCtrl.text.trim(),
        precioPorHora: precio,
        direccion: _direccionCtrl.text.trim(),
        latitud: latitud,
        longitud: longitud,
        fotosUrl: fotos,
        horariosDisponibles: horarios,
      );
      if (!_empresaCtrl.estaVerificada) {
        Get.snackbar('Empresa no aprobada', 'No puedes registrar canchas hasta que tu empresa sea verificada.',
            backgroundColor: Colors.orange[50], colorText: Colors.orange[800]);
        return;
      }
      final ok = await _canchaCtrl.registrarCancha(nueva);
      if (ok) Get.offAllNamed('/home-empresa');
    }
  }

  void _mostrarSelectorDeporte() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
          Text('Selecciona el deporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    if (!_empresaCtrl.estaVerificada) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Acceso denegado', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green[100],
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.orange[700]),
                const SizedBox(height: 20),
                Text('Tu empresa aún no ha sido aprobada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 10),
                Text('No puedes registrar canchas ni usar funcionalidades hasta que un administrador apruebe tu empresa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                  child: const Text('Volver', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicion ? 'Editar Cancha' : 'SportRent',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Text(_modoEdicion ? 'Editar Cancha' : 'Registrar Cancha',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                _modoEdicion
                    ? 'Modifica los datos de tu cancha deportiva'
                    : 'Completa la información de tu cancha deportiva',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            _seccionTitulo('Información básica'),
            customField('Nombre de la cancha', Icons.sports_soccer_outlined,
                controller: _nombreCtrl),
            customField('Descripción', Icons.description_outlined,
                controller: _descripcionCtrl),
            customField('Precio por hora (COP)', Icons.attach_money_outlined,
                controller: _precioCtrl, keyboardType: TextInputType.number),
            _campoDireccion(),

            _seccionTitulo('Tipo de deporte'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 6),
              child: GestureDetector(
                onTap: _mostrarSelectorDeporte,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _deporteSeleccionado != null
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: _deporteSeleccionado != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sports_outlined,
                          color: _deporteSeleccionado != null
                              ? Colors.green[700]
                              : Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deporteSeleccionado ?? 'Selecciona el tipo de deporte',
                          style: TextStyle(
                            fontSize: 16,
                            color: _deporteSeleccionado != null
                                ? Colors.black87
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),

            _seccionTitulo('Fotos de la cancha'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  if (_fotosUrls.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fotosUrls.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: _subiendo[i]
                                    ? Center(
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.green[700]),
                                        ),
                                      )
                                    : _fotosUrls[i].isNotEmpty
                                        ? Image.memory(
                                            base64Decode(
                                                _fotosUrls[i].split(',').last),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Icon(
                                                Icons.broken_image_outlined,
                                                color: Colors.green[700]),
                                          )
                                        : Icon(Icons.image_outlined,
                                            color: Colors.green[700]),
                              ),
                            ),
                            if (!_subiendo[i])
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _eliminarFoto(i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red[400], shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _subiendo.any((s) => s) ? null : _agregarFoto,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Agregar foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                    return HorarioItem(
                      index: i,
                      horario: entry.value,
                      onEliminar: () => _eliminarHorario(i),
                      onCambio: (nuevo) => setState(() => _horarios[i] = nuevo),
                    );
                  }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _agregarHorario,
                    icon: const Icon(Icons.add_alarm_outlined),
                    label: const Text('Agregar horario'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Obx(() => customButton(
                  _modoEdicion ? 'Guardar Cambios' : 'Registrar Cancha',
                  isLoading: _canchaCtrl.isLoading.value,
                  onPressed: _guardar,
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _campoDireccion() {
    final tieneUbicacion = _selectedLatLng != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: TextField(
        controller: _direccionCtrl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: 'Dirección o nombre del lugar',
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: tieneUbicacion ? Colors.green[700] : null,
          ),
          suffixIcon: IconButton(
            tooltip: 'Seleccionar en mapa',
            icon: Icon(Icons.map_outlined,
                color: tieneUbicacion ? Colors.green[700] : Colors.grey[600]),
            onPressed: _abrirMapaPicker,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: tieneUbicacion ? Colors.green : Colors.grey.shade400,
              width: tieneUbicacion ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.green[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 4),
      child: Text(titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}
