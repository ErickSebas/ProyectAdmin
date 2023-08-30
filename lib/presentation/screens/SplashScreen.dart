/// <summary>
/// Nombre de la aplicación: AdminMaYpiVaC
/// Nombre del desarrollador: Equipo-Sedes-Univalle
/// Fecha de creación: 18/08/2023
/// </summary>
///
// <copyright file="SplashScreen.dart" company="Sedes-Univalle">
// Esta clase está restringida para su uso, sin la previa autorización de Sedes-Univalle.
// </copyright>

import 'package:admin/presentation/screens/Login.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Navegar_Pantalla_Main();
  }

  Future<void> Navegar_Pantalla_Main() async {
    await Future.delayed(const Duration(seconds: 2)); // Espera 2 segundos
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Establece el color de fondo de tu splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo del splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 500,
                width: 500,
                child: Column(
                  children: [
                    Image.asset("assets/icon.png", height: 150, width: 150),
                    SizedBox(height: 10),
                  ],
                )),
            //FlutterLogo(size: 150),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF86ABF9)),
            )
          ],
        ),
      ),
    );
  }
}
