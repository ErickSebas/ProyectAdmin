import 'dart:convert';

import 'package:admin/Models/ChatModel.dart';
import 'package:admin/Models/ConversationModel.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;  
  
  
  Future<List<ChatMessage>> fetchMessage(BuildContext context, int idChat) async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/getmessage/'+idChat.toString())); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ChatMessage.fromJson(data)).toList();
  } else {
    showSnackbar(context, "Fallo al obtener los Chats");
    return [];
  }
}

  Future<int> getLastIdChat(BuildContext context) async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/lastidchat/')); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    var res = jsonResponse[0]['AUTO_INCREMENT'];
    return res;
  } else {
    showSnackbar(context, "Fallo al obtener id");
    return 0;
  }
}

  Future<int> getIdPersonByEMail(String correo) async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/getpersonbyemail/'+correo)); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['idPerson']);
    var res = jsonResponse[0]['idPerson'];
    return res;
  } else {
    return 0;
  }
}

  Future<void> deleteChat(BuildContext context, int idChat) async {
  final response = await http
      .put(Uri.parse('http://181.188.191.35:3000/deletechat/'+idChat.toString())); //192.168.14.112
   if (response.statusCode != 200 && response.statusCode != 201) {
    showSnackbar(context, "Error: " + response.body.toString());
  }
}

  Future<int> getIdRolByIdPerson(int id) async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/getidrol/'+id.toString())); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['idRol']);
    var res = jsonResponse[0]['idRol'];
    return res;
  } else {
    return 0;
  }
}


Future<void> registerNewChat(BuildContext context, Chat newChat) async {
  // Convertir tu objeto Campaign a JSON.
  final campaignJson = json.encode({
//'idCampañas': newCampaign.id,
    'idPerson': newChat.idPerson,
    'idPersonDestino': newChat.idPersonDestino,
  });
  final response = await http.post(
    Uri.parse('http://181.188.191.35:3000/insertchat'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: campaignJson,
  );
  if (response.statusCode != 200 && response.statusCode != 201) {
    showSnackbar(context, "Error: " + response.body.toString());
  }
}

  Future<void> sendMessage(BuildContext context, int idPerson, String mensaje, int idChat) async {
    final url = 'http://181.188.191.35:3000/sendmessage';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'idPerson': idPerson,
        'mensaje': mensaje,
        'idChat': idChat,
        'Nombres': miembroActual!.names,
      }),
    );

    if (response.statusCode != 200) {
      showSnackbar(context, "Error: " + response.body.toString());
    }
  }


