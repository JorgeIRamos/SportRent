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
import 'package:sport_rent/rutas/app_routes.dart';

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
            borderSide: const BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.green),
        ),
      ),
      initialBinding: _AppBindings(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
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
