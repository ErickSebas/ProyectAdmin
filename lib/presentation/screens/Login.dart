import 'dart:convert';
import 'dart:math';
import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/ChangePassword.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeClient.dart';
import 'Campaign.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Member? globalLoggedInMember;

  Future<Member?> authenticateHttp(String email, String password) async {
    final url = Uri.parse(
        'http://181.188.191.35:3000/user?correo=$email&password=$password');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final member = Member.fromJson(data);

      miembroActual = member;

      insertToken();

      return member;
    } else if (response.statusCode == 404) {
      return null; // Usuario no encontrado
    } else {
      throw Exception('Error al autenticar el usuario');
    }
  }

  insertToken() async {
    final url = 'http://181.188.191.35:3000/inserttoken';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'idPerson': miembroActual!.id,
        'token': token,
      }),
    );

    if (response.statusCode != 200) {
      print('Error al insertar el token');
    }
  }

  Future<Member?> recoverPassword(String email) async {
    final url = Uri.parse('http://181.188.191.35:3000/checkemail/$email');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      globalLoggedInMember = Member.fromJson2(data);

      return globalLoggedInMember;
    } else if (response.statusCode == 404) {
      return null; // Correo no encontrado en la base de datos
    } else {
      throw Exception('Error al recuperar la contraseña');
    }
  }

  Future<bool> sendEmailAndUpdateCode(int userId) async {
    final code = generateRandomCode();
    final exists = await checkCodeExists(userId);
    final smtpServer = gmail('bdcbba96@gmail.com', 'ehbh ugsw srnj jxsf');
    final message = Message()
      ..from = Address('bdcbba96@gmail.com', 'Admin')
      ..recipients.add(globalLoggedInMember!.correo)
      ..subject = 'Cambiar Contraseña MaYpiVaC'
      ..text = 'Código de recuperación de contraseña: $code';
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      // Actualiza la base de datos
      final url = exists
          ? Uri.parse(
              'http://181.188.191.35:3000/updateCode/$userId/$code') // URL para actualizar el código
          : Uri.parse(
              'http://181.188.191.35:3000/insertCode/$userId/$code'); // URL para insertar un nuevo registro
      final response = await (exists ? http.put(url) : http.post(url));
      if (response.statusCode == 200) {
        print('Código actualizado/insertado en la base de datos.');
        return true; // Devuelve true si todo fue exitoso
      } else {
        print('Error al actualizar/insertar el código en la base de datos.');
        return false; // Devuelve false en caso de error
      }
    } catch (e) {
      print('Message not sent.');
      print(e.toString());
      return false; // Devuelve false en caso de error
    }
  }

  String generateRandomCode() {
    final random = Random();
    final firstDigit =
        random.nextInt(9) + 1; // Genera un número aleatorio entre 1 y 9
    final restOfDigits = List.generate(4, (index) => random.nextInt(10)).join();
    final code = '$firstDigit$restOfDigits';
    return code;
  }

  Future<bool> checkCodeExists(int userId) async {
    var userId = globalLoggedInMember?.id;
    final response = await http.get(
      Uri.parse(
          'http://181.188.191.35:3000/checkCodeExists/$userId'), // Reemplaza con la URL correcta de tu API
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[
          'exists']; // Suponiendo que la API devuelve un booleano llamado "exists"
    } else {
      throw Exception('Error al verificar el código.');
    }
  }

  Future<void> tryAutoLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('miembroLocal');
    print(memberId);
    if (memberId != null) {
      // Si existe un memberId en la caché, realizar una solicitud HTTP para obtener detalles del miembro.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Espere unos momentos....'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Center(
                    child: SpinKitFadingCube(
                      color: Colors.blue, // Color de la animación
                      size: 50.0, // Tamaño de la animación
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final member = await fetchMemberById(memberId);
      miembroActual = member;

      if (member != null) {
        // Navega a la página CampaignProvider con la información del miembro obtenida.
        Navigator.of(context, rootNavigator: true).pop();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => CampaignProvider(),
              child: CampaignPage(),
            ),
          ),
        );
      }
    }
  }

 

  Future<Member?> fetchMemberById(int memberId) async {
    final url =
        Uri.parse('http://181.188.191.35:3000/userbyid?idUser=$memberId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final member = Member.fromJson(data);
      return member;
    } else {
      return null;
    }
  }
   Future<void> saveMemberIdToCache(int memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('miembroLocal', memberId);
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    String email = '';
    final loggedInMember = await showDialog<Member?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingrese el correo '),
          content: TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: InputDecoration(labelText: 'Correo Electrónico'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Mostrar el mensaje de espera
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Espere unos 3 segundos por favor...'),
                      content: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
                final member = await recoverPassword(email);
                Future.microtask(() async {
                  final success = await sendEmailAndUpdateCode(member!.id);

                  // Cerrar el diálogo de espera
                  Navigator.of(context, rootNavigator: true).pop();

                  Navigator.of(context)
                      .pop(member); // Cerrar el diálogo y pasar el resultado
                  if (success) {
                    isLogin = 1;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordPage(
                          member: globalLoggedInMember,
                        ),
                      ),
                    );
                    Mostrar_Mensaje(
                      context,
                      "Se ha enviado un código a tu correo electrónico.",
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Ocurrió un error al enviar el código de recuperación.'),
                      ),
                    );
                  }
                });
              },
              child: Text('Recuperar Contraseña'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/LogoHorizontal.png",
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      _showEmailDialog(context);
                      isLogin =
                          1; // Mostrar el diálogo de recuperación de contraseña
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final loggedInMember = await authenticateHttp(
                      emailController.text,
                      md5
                          .convert(utf8.encode(passwordController.text))
                          .toString());

                  if (loggedInMember != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => CampaignProvider(),
                          child: CampaignPage(),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Usuario o Contraseña Incorrectos')),
                    );
                  }
                },
                child: Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
