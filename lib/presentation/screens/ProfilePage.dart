import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

 

class ProfilePage extends StatelessWidget {

  final Member? member;

 

  ProfilePage({required this.member});

 

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de ${member!.name}"),
        backgroundColor: Color(0xFF4D6596),
         leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => CampaignProvider(), 
                  child: CampaignPage())),
                );
              },
            ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nombre: ${member!.name}"),
            Text("ID: ${member!.id}"),
            Text("Rol: ${member!.role}"),
            Text("correo: ${member!.correo}"),
            Text("contraseña: ${member!.contrasena}"),
            // Agrega más detalles del perfil aquí
          ],
        ),
      ),
    );
  }
}

 