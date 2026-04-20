import 'package:flutter/material.dart';
import 'package:sport_rent/ui/widgets/custom_buttom.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';

class Register extends StatefulWidget {

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0,),
            child: customText( 'Regístrate como usuario o empresa para comenzar a reservar tus espacios deportivos favoritos'),
          ),

          SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0,),
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
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('USUARIO'),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('EMPRESA'),
                  ),
                ),
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

class _UsuarioForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          customField('Nombre completo', Icons.person_outline),
          customField('Correo electrónico', Icons.email_outlined),
          customField('Telefono', Icons.phone_outlined),
          customField('Contraseña', Icons.lock_outline, obscure: true),
          customField('Confirmar contraseña', Icons.lock_outline, obscure: true),
          SizedBox(height: 24),
          customButtom('Registrarse'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta? '),
                GestureDetector(
                 onTap: () {},
                child: Text(
                'Inicia sesión',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
               ),
              ],
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EmpresaForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          customField('Responsable Legal / Contacto', Icons.person_outline),
          customField('NIT / ID de la empresa', Icons.lock_outline, obscure: true),
          customField('Nombre de la empresa', Icons.business_outlined),
          customField('Teléfono de contacto', Icons.phone_outlined),
          customField('Email del contacto', Icons.email_outlined),
          customField('Contraseña', Icons.lock_outline, obscure: true),
          customField('Confirmar contraseña', Icons.lock_outline, obscure: true),
          SizedBox(height: 24),
          customButtom('Registrarse'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta? '),
                GestureDetector(
                 onTap: () {},
                child: Text(
                'Inicia sesión',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
               ),
              ],
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

Widget customText(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16, color: Colors.grey),
  );
}

