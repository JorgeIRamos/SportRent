import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/ui/pages/admin/widgets/home_admin_widgets.dart';

class AdminEmpresasBody extends StatelessWidget {
  const AdminEmpresasBody({super.key});

  @override
  Widget build(BuildContext context) {
    final empresaCtrl = Get.find<EmpresaController>();

    return Obx(() {
      final empresas = empresaCtrl.todasEmpresas;
      final pendientes = empresas.where((e) => !e.verificada).toList();

      if (empresaCtrl.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Colors.green[700]));
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Todas las empresas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (pendientes.isNotEmpty) ...[
            Text('Pendientes de verificación (${pendientes.length})',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700])),
            const SizedBox(height: 8),
            ...pendientes.map((e) => EmpresaPendienteCard(
                  empresa: e,
                  onAprobar: () => empresaCtrl.verificarEmpresa(e.id),
                  onRechazar: () => empresaCtrl.rechazarEmpresa(e.id),
                )),
            const SizedBox(height: 16),
            const Text('Todas',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
          ...empresas.map((e) => EmpresaRow(empresa: e)),
        ],
      );
    });
  }
}
