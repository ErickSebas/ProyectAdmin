/// <summary>
/// Nombre de la aplicación: AdminMaYpiVaC
/// Nombre del desarrollador: Equipo-Sedes-Univalle
/// Fecha de creación: 18/08/2023
/// </summary>
/// 
// <copyright file="services_firebase.dart" company="Sedes-Univalle">
// Esta clase está restringida para su uso, sin la previa autorización de Sedes-Univalle.
// </copyright>


import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'package:admin/Models/ChatModel.dart';
import 'package:admin/Models/ConversationModel.dart';
import 'package:admin/Models/Profile.dart';
import 'package:admin/Models/Ubication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';


import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:admin/presentation/screens/Campaign.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
double? proceso = 0.0;
Member? miembroActual;
bool esCarnetizador = false;
int idCamp = 0;
List<ChatMessage> messages = [];
List<Chat> chats = [];
List<dynamic> namesChats=[];
int idChatActual=0;
late IO.Socket socket;
int isLogin = 0;
String? token;
int currentChatId = 0;


// Método guardar Archivo JSON
Future<File> _saveJsonInStorage(String jsonData) async {
  final directorio = await getApplicationDocumentsDirectory();
  final file = File('${directorio.path}/campana'+idCamp.toString()+'.json');
  return file.writeAsString(jsonData);
}

Future<void> eliminarArchivoDeStorage(int id) async {
  Reference ref = storage.ref().child('campana' + id.toString() + '.json');
  try {
    await ref.delete();
    print("Archivo eliminado correctamente.");
  } catch (e) {
    print("Error al eliminar el archivo: $e");
  }
}

Future<void> Subir_Json_Firebase(int id,List<EUbication> Ubicaciones, Function(double) enProceso) async {
    idCamp = id;
    String jsonUbication = jsonEncode(Ubicaciones.map((p) => p.toJson()).toList());
    File file = await _saveJsonInStorage(jsonUbication);
    Reference ref = storage.ref().child('campana'+idCamp.toString()+'.json');
    UploadTask uploadTask = ref.putFile(file);

    // Escucha los cambios en el progreso de la tarea
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double currentProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        enProceso(currentProgress);
    });
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    await uploadTask.whenComplete(() => {});
    var url = await taskSnapshot.ref.getDownloadURL();
    print("URL del archivo: $url");
}

  void Mostrar_Error(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: Text('Aceptar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  void Mostrar_Finalizado(BuildContext context, String texto) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(texto),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Hecho', style: TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => CampaignProvider(), 
                child: CampaignPage())),
              );
            },
          ),
        ],
      );
    },
  );
}



  Future<void> Mostrar_Mensaje(BuildContext context, String texto)async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(texto),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Hecho', style: TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}




