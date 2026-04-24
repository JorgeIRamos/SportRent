import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/calificacion_controller.dart';
import 'package:sport_rent/models/reserva_model.dart';

class CalificacionSheet extends StatefulWidget {
  final Reserva reserva;
  final CalificacionController calificacionCtrl;
  final AuthController authCtrl;
  final VoidCallback onCalificado;

  const CalificacionSheet({
    super.key,
    required this.reserva,
    required this.calificacionCtrl,
    required this.authCtrl,
    required this.onCalificado,
  });

  @override
  State<CalificacionSheet> createState() => _CalificacionSheetState();
}

class _CalificacionSheetState extends State<CalificacionSheet> {
  int _puntuacion = 0;
  final _comentarioCtrl = TextEditingController();
  bool _enviando = false;

  static const _etiquetas = ['', 'Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente'];

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_puntuacion == 0) {
      Get.snackbar(
        'Elige una puntuación',
        'Selecciona entre 1 y 5 estrellas antes de enviar.',
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _enviando = true);
    final uid = widget.authCtrl.usuario.value?.id ?? '';
    final ok = await widget.calificacionCtrl.calificar(
      usuarioId: uid,
      canchaId: widget.reserva.canchaId,
      reservaId: widget.reserva.id,
      puntuacion: _puntuacion,
      comentario: _comentarioCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _enviando = false);
      if (ok) {
        Navigator.pop(context);
        widget.onCalificado();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('¿Cómo fue tu experiencia?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(
              widget.reserva.nombreCancha ?? 'Cancha',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final estrella = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _puntuacion = estrella),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      estrella <= _puntuacion ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 48,
                      color: estrella <= _puntuacion ? Colors.amber[500] : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _puntuacion > 0
                  ? Padding(
                      key: ValueKey(_puntuacion),
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _etiquetas[_puntuacion],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700]),
                      ),
                    )
                  : const SizedBox(key: ValueKey(0), height: 8),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia (opcional)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: Colors.grey[50],
                counterStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _enviando ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _enviando ? null : _enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[500],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Enviar calificación',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
