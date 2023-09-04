import 'package:flutter/material.dart';
import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/presentation/screens/List_members.dart';
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
              if (estadoPerfil == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                          create: (context) => CampaignProvider(),
                          child: CampaignPage())),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListMembersScreen()),
                );
              }
            },
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF4D6596), // Color de fondo para toda la pantalla
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: 1.0, // Establece el ancho al 100% de la pantalla
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco para esta parte
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80), // Aumenta el radio aquí
                    bottomRight: Radius.circular(80), // Aumenta el radio aquí
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16), // Aumenta el espacio horizontal
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${member!.name}",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4D6596)),
                    ),
                    Text(
                      "${member!.role}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem("Correo: ${member!.correo}"),
                    _buildInfoItem("Carnet: ${member!.carnet}"),
                    _buildInfoItem("Teléfono: ${member!.telefono}"),
                    _buildInfoItem(
                        "Fecha de Nacimiento: ${member!.datebirthday}"),
                    _buildInfoItem("Longitud: ${member!.longitud}"),
                    _buildInfoItem("Latitud: ${member!.latitud}"),
                    SizedBox(height: 20), // Espacio entre los datos y el botón
                    ElevatedButton(
                      onPressed: () {
                        // Agrega aquí la lógica para editar el perfil
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 255, 255,
                            255), // Cambia el color de fondo del botón
                        padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15), // Aumenta el espacio interno
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Ajusta el radio para hacerlo circular
                        ),
                      ),
                      child: Text(
                        "Editar Perfil",
                        style: TextStyle(
                          color: Color(
                              0xFF4D6596), // Cambia el color del texto del botón
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    final List<String> parts =
        text.split(":"); // Dividimos el texto en dos partes

    return Container(
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 20),
          children: [
            TextSpan(
              text: "${parts[0]}: ", // Parte del título en negrita
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: parts[1], // Parte del contenido
            ),
          ],
        ),
      ),
    );
  }
}
