/// <summary>
/// Nombre de la aplicación: AdminMaYpiVaC
/// Nombre del desarrollador: Equipo-Sedes-Univalle
/// Fecha de creación: 18/08/2023
/// </summary>
/// 
// <copyright file="main.dart" company="Sedes-Univalle">
// Esta clase está restringida para su uso, sin la previa autorización de Sedes-Univalle.
// </copyright>


import 'package:admin/Presentation/Screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext  context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E1670)),
          primaryColor: const Color(0xFF7E1670),
        ),
        initialRoute: '/home',
        routes: {
          //Pantalla principal
          '/home': (context) => const SplashScreen(),
        },
      );
  }
}

 