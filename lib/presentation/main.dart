import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:admin/Models/Ubication.dart';
import 'Screens/SplashScreen.dart';


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

 