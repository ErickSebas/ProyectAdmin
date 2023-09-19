import 'dart:convert';

import 'package:admin/Models/ConversationModel.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final int idPerson;
  final String mensaje;
  final int idChat;
  final String nombres;

  ChatMessage({required this.idPerson,required this.mensaje, required this.idChat, required this.nombres});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      idPerson: json['idPerson'],
      mensaje: json['mensaje'],
      idChat: json['idChat'],
      nombres: json['Nombres'],
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $idPerson, message: $mensaje, idChat: $idChat, Nombres: $nombres)';
  }

}

  Future<List<ChatMessage>> fetchMessage(int idChat) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:3000/getmessage/'+idChat.toString())); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ChatMessage.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load campaigns');
  }
}

  Future<int> getLastIdChat() async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/lastidchat/')); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    var res = jsonResponse[0]['AUTO_INCREMENT'];
    return res;
  } else {
    throw Exception('Failed to load id');
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

  Future<int> getIdRolByIdPerson(int id) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2/getidrol/'+id.toString())); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['idRol']);
    var res = jsonResponse[0]['idRol'];
    return res;
  } else {
    return 0;
  }
}


Future<void> registerNewChat(Chat newChat) async {
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
    throw Exception(response);
  }
}


