import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/ui/widgets/custom_buttom.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().limpiarError();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 30),
          Text(
            'Crear cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Regístrate como usuario o empresa para comenzar a reservar tus espacios deportivos favoritos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.greenAccent[400],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              tabs: [
                Tab(child: Container(padding: EdgeInsets.symmetric(vertical: 12), child: Text('USUARIO'))),
                Tab(child: Container(padding: EdgeInsets.symmetric(vertical: 12), child: Text('EMPRESA'))),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UsuarioForm(),
                _EmpresaForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FORMULARIO USUARIO ────────────────────────────────────────────────────────

class _UsuarioForm extends StatefulWidget {
  @override
  State<_UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<_UsuarioForm> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _registrar() {
    _auth.limpiarError();

    if (_passCtrl.text != _confirmPassCtrl.text) {
      Get.snackbar('Error', 'Las contraseñas no coinciden',
          backgroundColor: Colors.red[50], colorText: Colors.red[700]);
      return;
    }

    _auth.register(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      telefono: _telefonoCtrl.text.trim(),
      rol: 'cliente',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          customField('Nombre completo', Icons.person_outline, controller: _nombreCtrl),
          customField('Correo electrónico', Icons.email_outlined,
              controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
          customField('Teléfono', Icons.phone_outlined,
              controller: _telefonoCtrl, keyboardType: TextInputType.phone),
          customField('Contraseña', Icons.lock_outline,
              controller: _passCtrl, obscure: true),
          customField('Confirmar contraseña', Icons.lock_outline,
              controller: _confirmPassCtrl, obscure: true),

          // Error
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
          Obx(() => customButtom('Registrarse',
              isLoading: _auth.isLoading.value, onPressed: _registrar)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Ya tienes cuenta? '),
              GestureDetector(
                onTap: () => Get.toNamed('/login'),
                child: Text('Inicia sesión',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── FORMULARIO EMPRESA ────────────────────────────────────────────────────────

class _EmpresaForm extends StatefulWidget {
  @override
  State<_EmpresaForm> createState() => _EmpresaFormState();
}

class _EmpresaFormState extends State<_EmpresaForm> {
  final _responsableCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _nombreEmpresaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _responsableCtrl.dispose();
    _nitCtrl.dispose();
    _nombreEmpresaCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _registrar() {
    _auth.limpiarError();

    if (_passCtrl.text != _confirmPassCtrl.text) {
      Get.snackbar('Error', 'Las contraseñas no coinciden',
          backgroundColor: Colors.red[50], colorText: Colors.red[700]);
      return;
    }

    _auth.register(
      nombre: _responsableCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      telefono: _telefonoCtrl.text.trim(),
      rol: 'empresa',
      nombreEmpresa: _nombreEmpresaCtrl.text.trim(),
      nit: _nitCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          customField('Responsable Legal / Contacto', Icons.person_outline,
              controller: _responsableCtrl),
          customField('NIT / ID de la empresa', Icons.badge_outlined,
              controller: _nitCtrl),
          customField('Nombre de la empresa', Icons.business_outlined,
              controller: _nombreEmpresaCtrl),
          customField('Teléfono de contacto', Icons.phone_outlined,
              controller: _telefonoCtrl, keyboardType: TextInputType.phone),
          customField('Email del contacto', Icons.email_outlined,
              controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
          customField('Contraseña', Icons.lock_outline,
              controller: _passCtrl, obscure: true),
          customField('Confirmar contraseña', Icons.lock_outline,
              controller: _confirmPassCtrl, obscure: true),

          // Error
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
          Obx(() => customButtom('Registrarse',
              isLoading: _auth.isLoading.value, onPressed: _registrar)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Ya tienes cuenta? '),
              GestureDetector(
                onTap: () => Get.toNamed('/login'),
                child: Text('Inicia sesión',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
