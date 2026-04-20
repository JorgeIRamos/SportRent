import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/ui/widgets/custom_buttom.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
            SizedBox(height: 40),
            Text(
              '¡Bienvenido!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Inicia sesión para continuar con tus reservas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),

            customField('Correo electrónico', Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress),

            customField('Contraseña', Icons.lock_outline,
                controller: _passCtrl, obscure: true),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 30),
                child: TextButton(
                  onPressed: () => Get.snackbar(
                    'Recuperar contraseña',
                    'Función disponible próximamente',
                    backgroundColor: Colors.green[100],
                    colorText: Colors.black87,
                  ),
                  child: Text('¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.green[700])),
                ),
              ),
            ),

            // Mensaje de error
            Obx(() {
              if (_auth.error.value.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400], size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(_auth.error.value,
                            style: TextStyle(color: Colors.red[700], fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 20),

            Obx(() => customButtom(
                  'Iniciar Sesión',
                  isLoading: _auth.isLoading.value,
                  onPressed: () {
                    _auth.limpiarError();
                    _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
                  },
                )),

            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿No tienes cuenta? '),
                GestureDetector(
                  onTap: () => Get.toNamed('/register'),
                  child: Text(
                    'Regístrate',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
