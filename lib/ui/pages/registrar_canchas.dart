import 'package:flutter/material.dart';
import 'package:sport_rent/ui/widgets/custom_buttom.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';
import 'package:sport_rent/ui/widgets/custom_timepicker.dart';

class RegistrarCancha extends StatefulWidget {
  const RegistrarCancha({super.key});

  @override
  State<RegistrarCancha> createState() => _RegistrarCanchaState();
}

class _RegistrarCanchaState extends State<RegistrarCancha> {
  final List<String> _fotosAgregadas = [];

  final List<Map<String, String>> _horarios = [];

  void _agregarHorario() {
    setState(() {
      _horarios.add({'dia': 'Lunes', 'inicio': '08:00', 'fin': '22:00'});
    });
  }

  void _eliminarHorario(int index) {
    setState(() {
      _horarios.removeAt(index);
    });
  }

  void _agregarFotoSimulada() {
    setState(() {
      _fotosAgregadas.add('foto_${_fotosAgregadas.length + 1}.jpg');
    });
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotosAgregadas.removeAt(index);
    });
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

            Text(
              'Registrar Cancha',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),

            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Completa la información de tu cancha deportiva',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            SizedBox(height: 20),

            _seccionTitulo('Información básica'),

            customField('Nombre de la cancha', Icons.sports_soccer_outlined),
            customField('Descripción', Icons.description_outlined),
            customField('Precio por hora (COP)', Icons.attach_money_outlined),
            customField('Dirección', Icons.location_on_outlined),

            _seccionTitulo('Tipo de deporte'),

            customField('Ej: Fútbol, Baloncesto, Tenis...', Icons.sports_outlined),

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
                        separatorBuilder: (_, _) => SizedBox(width: 10),
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
                                    color: Colors.red[400],
                                    shape: BoxShape.circle,
                                  ),
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
            customButtom('Registrar Cancha'),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 4),
      child: Text(
        titulo,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
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
              items: _dias.map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) => onCambio({...horario, 'dia': val!}),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(context, 'Inicio', horario['inicio']!, (v) => onCambio({...horario, 'inicio': v})),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: customTimepicker(context, 'Fin', horario['fin']!, (v) => onCambio({...horario, 'fin': v})),
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
