import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';

class PerfilTabUsuario extends StatelessWidget {
  final AuthController authCtrl;

  const PerfilTabUsuario({super.key, required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final usuario = authCtrl.usuario.value;
      final nombre = usuario?.nombre ?? '';
      final email = usuario?.email ?? '';
      final telefono = usuario?.telefono ?? '';

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.green[300],
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.greenAccent[400],
                              shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(nombre,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SeccionPerfil(titulo: 'Información personal', items: [
                    _InfoItem(
                        icono: Icons.person_outline,
                        label: 'Nombre',
                        valor: nombre.isNotEmpty ? nombre : '—'),
                    _InfoItem(
                        icono: Icons.phone_outlined,
                        label: 'Teléfono',
                        valor: telefono.isNotEmpty ? telefono : '—'),
                    _InfoItem(
                        icono: Icons.email_outlined,
                        label: 'Correo',
                        valor: email.isNotEmpty ? email : '—'),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _OpcionItem(
                      icono: Icons.lock_outline,
                      label: 'Cambiar contraseña',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.help_outline,
                      label: 'Ayuda y soporte',
                      onTap: () {}),
                  _OpcionItem(
                      icono: Icons.policy_outlined,
                      label: 'Términos y condiciones',
                      onTap: () {}),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => authCtrl.logout(),
                      icon: Icon(Icons.logout, color: Colors.red[600]),
                      label: Text('Cerrar sesión',
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

class _SeccionPerfil extends StatelessWidget {
  final String titulo;
  final List<Widget> items;

  const _SeccionPerfil({required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(titulo,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoItem({required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icono, size: 20, color: Colors.green[700]),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(valor,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}

class _OpcionItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _OpcionItem({required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: ListTile(
        leading: Icon(icono, color: Colors.green[700], size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
