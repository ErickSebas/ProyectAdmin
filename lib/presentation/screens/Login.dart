import 'package:admin/Models/Profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'HomeClient.dart';
import 'Campaign.dart';
import 'package:http/http.dart' as http;
import 'package:admin/services/services_firebase.dart';

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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Member? authenticate(String email, String password) {
    for (var member in members) {
      if (member.correo == email && member.contrasena == password) {
        miembroActual = member;
        return member;  
      }
    }
    return null;
  }


  Future<void> authenticateHttp(context) async {
    final response = await http.post(
      Uri.parse('https://localhost/login'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
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
        SnackBar(content: Text('Error al iniciar sesión')),
      );
    }
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
              Image.asset("assets/LogoNew.png", height: 130, width: 130),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo electronico'),
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
                    onTap: () {
                      //
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ]
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Member? loggedInMember = authenticate(emailController.text, passwordController.text);
                  if (loggedInMember != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => CampaignProvider(), 
                      child: CampaignPage())),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al iniciar sesión')),
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
