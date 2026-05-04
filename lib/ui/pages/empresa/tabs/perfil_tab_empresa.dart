import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';

class PerfilTabEmpresa extends StatelessWidget {
  const PerfilTabEmpresa({super.key});

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return 'E';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      final canchaCtrl = Get.find<CanchaController>();
      final reservaCtrl = Get.find<ReservaController>();
      final empresaCtrl = Get.find<EmpresaController>();
      final usuario = auth.usuario.value;

      final nombre = usuario?.nombre ?? '';
      final nombreEmpresa = empresaCtrl.nombreEmpresa;
      final nit = empresaCtrl.nit;
      final email = usuario?.email ?? '';
      final telefono = usuario?.telefono ?? '';

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              color: Colors.green[100],
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.green[200],
                        child: Text(_iniciales(nombreEmpresa.isNotEmpty ? nombreEmpresa : nombre),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.greenAccent[400], shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(nombreEmpresa.isNotEmpty ? nombreEmpresa : (nombre.isNotEmpty ? nombre : 'Mi Empresa'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        empresaCtrl.estaVerificada ? Icons.verified : Icons.hourglass_top,
                        size: 15,
                        color: empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        empresaCtrl.estaVerificada ? 'Empresa verificada' : 'Empresa sin aprobar',
                        style: TextStyle(
                          fontSize: 13,
                          color: empresaCtrl.estaVerificada ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SeccionPerfilEmpresa(titulo: 'Información de la empresa', items: [
              InfoItemEmpresa(icono: Icons.business_outlined, label: 'Empresa', valor: nombreEmpresa.isNotEmpty ? nombreEmpresa : 'â€”'),
              InfoItemEmpresa(icono: Icons.badge_outlined, label: 'NIT', valor: nit.isNotEmpty ? nit : 'â€”'),
              InfoItemEmpresa(icono: Icons.person_outline, label: 'Responsable', valor: nombre.isNotEmpty ? nombre : 'â€”'),
              InfoItemEmpresa(icono: Icons.phone_outlined, label: 'Teléfono', valor: telefono.isNotEmpty ? telefono : 'â€”'),
              InfoItemEmpresa(icono: Icons.email_outlined, label: 'Correo', valor: email.isNotEmpty ? email : 'â€”'),
            ]),

            const SizedBox(height: 12),

            SeccionPerfilEmpresa(titulo: 'Resumen de actividad', items: [
              InfoItemEmpresa(
                  icono: Icons.sports_soccer_outlined,
                  label: 'Canchas registradas',
                  valor: canchaCtrl.canchas.length.toString()),
              InfoItemEmpresa(
                  icono: Icons.calendar_today_outlined,
                  label: 'Total reservas',
                  valor: reservaCtrl.reservas.length.toString()),
              InfoItemEmpresa(
                  icono: Icons.check_circle_outline,
                  label: 'Reservas confirmadas',
                  valor: reservaCtrl.totalConfirmadas.toString()),
            ]),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  OpcionItemEmpresa(icono: Icons.lock_outline, label: 'Cambiar contraseña', onTap: () {}),
                  OpcionItemEmpresa(icono: Icons.notifications_outlined, label: 'Preferencias de notificación', onTap: () {}),
                  OpcionItemEmpresa(icono: Icons.help_outline, label: 'Ayuda y soporte', onTap: () {}),
                  OpcionItemEmpresa(icono: Icons.policy_outlined, label: 'Términos y condiciones', onTap: () {}),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => auth.logout(),
                      icon: Icon(Icons.logout, color: Colors.red[600]),
                      label: Text('Cerrar sesión',
                          style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}
