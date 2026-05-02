import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/auth_controller.dart';
import 'package:sport_rent/models/cancha_model.dart';
import 'package:sport_rent/ui/pages/autenticacion/pages/login_page.dart';
import 'package:sport_rent/ui/pages/autenticacion/pages/register_page.dart';
import 'package:sport_rent/ui/pages/canchas/pages/disponibilidad_cancha_page.dart';
import 'package:sport_rent/ui/pages/canchas/pages/registrar_canchas_page.dart';
import 'package:sport_rent/ui/pages/admin/pages/home_admin_page.dart';
import 'package:sport_rent/ui/pages/empresa/pages/home_empresa_page.dart';
import 'package:sport_rent/ui/pages/home_principal/pages/home_page.dart';
import 'package:sport_rent/ui/pages/usuario/pages/home_usuario_page.dart';

abstract class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeUsuario = '/home-usuario';
  static const String homeEmpresa = '/home-empresa';
  static const String homeAdmin = '/home-admin';
  static const String registrarCancha = '/registrar-cancha';
  static const String disponibilidad = '/disponibilidad';
}

abstract class AppRoutesMap {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.home: (_) => const Home(),
        AppRoutes.login: (_) => const Login(),
        AppRoutes.register: (_) => const Register(),
        AppRoutes.homeEmpresa: (_) => const HomeEmpresa(),
        AppRoutes.homeAdmin: (_) => const HomeAdmin(),
        AppRoutes.registrarCancha: (_) => const RegistrarCancha(),
      };
}

abstract class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.home, page: () => const Home()),
    GetPage(name: AppRoutes.login, page: () => const Login()),
    GetPage(name: AppRoutes.register, page: () => const Register()),
    GetPage(
      name: AppRoutes.homeUsuario,
      page: () => HomeUsuario(
        nombreUsuario: Get.find<AuthController>().nombre,
      ),
    ),
    GetPage(name: AppRoutes.homeEmpresa, page: () => const HomeEmpresa()),
    GetPage(name: AppRoutes.homeAdmin, page: () => const HomeAdmin()),
    GetPage(
      name: AppRoutes.registrarCancha,
      page: () => const RegistrarCancha(),
    ),
    GetPage(
      name: AppRoutes.disponibilidad,
      page: () => DisponibilidadCancha(cancha: Get.arguments as Cancha),
    ),
  ];
}
