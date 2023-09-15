import 'dart:convert';

import 'package:admin/services/services_firebase.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final int idPerson;
  final String mensaje;
  final int idChat;

  ChatMessage({required this.idPerson,required this.mensaje, required this.idChat});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      idPerson: json['idPerson'],
      mensaje: json['mensaje'],
      idChat: json['idChat'],
    );
  }
}

  Future<List<ChatMessage>> fetchMessage(int idChat) async {
  final response = await http
      .get(Uri.parse('https://backendapi-398117.rj.r.appspot.com/getmessage/'+idChat.toString())); //192.168.14.112
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ChatMessage.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load campaigns');
  }
}

