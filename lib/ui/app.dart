import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/anuncio_controller.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/controllers/calificacion_controller.dart';
import 'package:sport_rent/controllers/cancha_controller.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/controllers/estadistica_controller.dart';
import 'package:sport_rent/controllers/favorito_controller.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/controllers/reserva_controller.dart';
import 'package:sport_rent/controllers/usuario_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/disponibilidad_cancha.dart';
import 'package:sport_rent/ui/pages/home.dart';
import 'package:sport_rent/ui/pages/home_admin.dart';
import 'package:sport_rent/ui/pages/home_empresa.dart';
import 'package:sport_rent/ui/pages/home_usuario.dart';
import 'package:sport_rent/ui/pages/login.dart';
import 'package:sport_rent/ui/pages/register.dart';
import 'package:sport_rent/ui/pages/registrar_canchas.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SportRent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.green),
        ),
      ),
      initialBinding: _AppBindings(),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const Home()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/register', page: () => Register()),
        GetPage(
          name: '/home-usuario',
          page: () => HomeUsuario(nombreUsuario: Get.find<AuthController>().nombre),
        ),
        GetPage(name: '/home-empresa', page: () => const HomeEmpresa()),
        GetPage(name: '/home-admin', page: () => const HomeAdmin()),
        GetPage(name: '/registrar-cancha', page: () => const RegistrarCancha()),
        GetPage(
          name: '/disponibilidad',
          page: () => DisponibilidadCancha(cancha: Get.arguments as Cancha),
        ),
      ],
    );
  }
}

class _AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(CanchaController(), permanent: true);
    Get.put(NotificacionController(), permanent: true);
    Get.put(ReservaController(), permanent: true);
    Get.put(UsuarioController(), permanent: true);
    Get.put(EmpresaController(), permanent: true);
    Get.put(CalificacionController(), permanent: true);
    Get.put(FavoritoController(), permanent: true);
    Get.put(EstadisticaController(), permanent: true);
    Get.put(AnuncioController(), permanent: true);
  }
}
