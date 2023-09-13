import 'dart:convert';

import 'package:admin/services/services_firebase.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final int idPerson;
  final int idPersonDestino;
  final String mensaje;

  ChatMessage({required this.idPerson,required this.idPersonDestino,required this.mensaje});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      idPerson: json['idPerson'],
      idPersonDestino: json['idPersonDestino'],
      mensaje: json['mensaje'],
    );
  }
}

  Future<List<ChatMessage>> fetchMessage() async {
  final response = await http
      .get(Uri.parse('http://192.168.14.112:3000/getmessage/'+miembroActual!.id.toString()));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ChatMessage.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load campaigns');
  }
}

