import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/ui/pages/registrar_canchas.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: RegistrarCancha(), 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(15)),
          floatingLabelStyle: const TextStyle(color: Colors.green),
          



        )
      ), 
      );
  }
}