import 'package:admin/presentation/screens/ChangePassword.dart';
import 'package:admin/presentation/screens/RegisterBoss.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/presentation/screens/List_members.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ProfilePage extends StatelessWidget {
  final Member? member;

  sendEmail() async {
    final smtpServer = gmail('bdcbba96@gmail.com', 'ehbh ugsw srnj jxsf');

    final message = Message()
      ..from = Address('bdcbba96@gmail.com', 'Admin')
      ..recipients.add(member!.correo)
      ..subject = 'Cambiar Contraseña MaYpiVaC'
      ..text = 'codigo';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent.');
      print(e.toString());
    }
  }

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
        color: Color(0xFF4D6596),
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
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
              child: SingleChildScrollView(
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
                      _buildMap(member!.latitud, member!.longitud),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterBossPage(
                                        initialData: Member(
                                            name: member!.name,
                                            datebirthday: member!.datebirthday,
                                            id: member!.id,
                                            role: member!.role,
                                            contrasena: "",
                                            correo: member!.correo,
                                            telefono: member!.telefono,
                                            carnet: member!.carnet,
                                            latitud: member!.latitud,
                                            longitud: member!.longitud))),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 255, 255, 255),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              "Editar Perfil",
                              style: TextStyle(
                                color: Color(0xFF4D6596),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await sendEmail();
                              await Mostrar_Mensaje(context,
                                  "Se ha enviado un código a tu correo electrónico.");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePasswordPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 255, 255, 255),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              "Cambiar Contraseña",
                              style: TextStyle(
                                color: Color(0xFF4D6596),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
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

Widget _buildMap(double lat, double lng) {
  return Container(
    height: 150, // Altura del cuadro del mapa
    width: double.infinity, // Ocupa todo el ancho disponible
    child: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId('memberLocation'),
          position: LatLng(lat, lng),
        ),
      },
    ),
  );
}
