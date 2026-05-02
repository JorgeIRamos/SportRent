import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';

void mostrarNotificacionesEmpresa(
    BuildContext context, NotificacionController notificacionCtrl) {
  notificacionCtrl.marcarTodasLeidas();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.notifications, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Notificaciones',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Obx(() {
                  final cargando = notificacionCtrl.isLoading.value;
                  return IconButton(
                    tooltip: 'Recargar',
                    onPressed: cargando
                        ? null
                        : () {
                            final uid =
                                Get.find<AuthController>().usuario.value?.id ??
                                    '';
                            if (uid.isNotEmpty) {
                              notificacionCtrl.cargarNotificaciones(uid);
                            }
                          },
                    icon: cargando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.green),
                          )
                        : Icon(Icons.refresh, size: 20, color: Colors.grey[700]),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: Obx(() {
              final err = notificacionCtrl.error.value;
              final lista = notificacionCtrl.notificaciones;

              if (err.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(err,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700])),
                  ),
                );
              }

              if (notificacionCtrl.isLoading.value && lista.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              }

              if (lista.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 58, color: Colors.grey[350]),
                      const SizedBox(height: 10),
                      Text('No tienes notificaciones',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller,
                itemCount: lista.length,
                itemBuilder: (_, i) => NotifItemFromModel(
                  notificacion: lista[i],
                  onTap: () => notificacionCtrl.marcarLeida(lista[i].id),
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}
