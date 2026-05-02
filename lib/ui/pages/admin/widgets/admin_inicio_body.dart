import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/ui/pages/admin/widgets/home_admin_widgets.dart';

class AdminInicioBody extends StatelessWidget {
  /// Called when the user taps "Ver todas las canchas" to switch to tab 1.
  final VoidCallback onVerCanchas;

  const AdminInicioBody({super.key, required this.onVerCanchas});

  @override
  Widget build(BuildContext context) {
    final canchaCtrl = Get.find<CanchaController>();
    final empresaCtrl = Get.find<EmpresaController>();

    return Obx(() {
      final canchas = canchaCtrl.canchas;
      final activas = canchas.where((c) => c.activa).length;
      final empresas = empresaCtrl.todasEmpresas;
      final pendientesVerif = empresas.where((e) => !e.verificada).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen general',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              children: [
                AdminStatCard(
                    label: 'Total canchas',
                    valor: '${canchas.length}',
                    icono: Icons.sports_soccer,
                    color: Colors.green[700]!),
                const SizedBox(width: 10),
                AdminStatCard(
                    label: 'Activas',
                    valor: '$activas',
                    icono: Icons.check_circle_outline,
                    color: Colors.teal[600]!),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                AdminStatCard(
                    label: 'Empresas',
                    valor: '${empresas.length}',
                    icono: Icons.business_outlined,
                    color: Colors.blue[700]!),
                const SizedBox(width: 10),
                AdminStatCard(
                    label: 'Sin verificar',
                    valor: '${pendientesVerif.length}',
                    icono: Icons.pending_outlined,
                    color: Colors.orange[700]!),
              ],
            ),
            if (pendientesVerif.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.pending_actions, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  const Text('Empresas pendientes de verificación',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 10),
              ...pendientesVerif.map((e) => EmpresaPendienteCard(
                    empresa: e,
                    onAprobar: () => empresaCtrl.verificarEmpresa(e.id),
                    onRechazar: () => empresaCtrl.rechazarEmpresa(e.id),
                  )),
            ],
            const SizedBox(height: 24),
            const Text('Canchas recientes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...canchas.take(2).map((c) => CanchaAdminRow(
                  cancha: c,
                  onToggle: () => canchaCtrl.toggleActiva(c.id),
                )),
            TextButton(
              onPressed: onVerCanchas,
              child: Text('Ver todas las canchas',
                  style: TextStyle(color: Colors.green[700])),
            ),
          ],
        ),
      );
    });
  }
}
