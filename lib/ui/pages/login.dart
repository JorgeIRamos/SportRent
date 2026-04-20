import 'package:flutter/material.dart';
import 'package:sport_rent/ui/widgets/custom_text_field.dart';

class Login extends StatelessWidget {
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
            SizedBox(height: 40),
            
            
            SizedBox(height: 20),
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
            
            SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              child: customField('email', Icons.email_outlined, obscure: true)
            ),
            

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              child: customField('contraseña', Icons.lock_outline, obscure: true)
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.green[700])),
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: Text('Iniciar Sesión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿No tienes cuenta? "),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Regístrate',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
      ),
    );
  }
}