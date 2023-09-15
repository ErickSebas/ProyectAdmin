import 'dart:convert';

import 'package:admin/services/services_firebase.dart';
import 'package:http/http.dart' as http;

class Chat {
  final int idChats;
  final int idPerson;
  final int idPersonDestino;
  final DateTime fechaActualizacion;

  Chat(
      {required this.idChats,
      required this.idPerson,
      required this.idPersonDestino,
      required this.fechaActualizacion});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      idChats: json['idChats'],
      idPerson: json['idPerson'],
      idPersonDestino: json['idPersonDestino'],
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }
}

Future<List<Chat>> fetchChats() async {
  final response = await http.get(Uri.parse(
      'https://backendapi-398117.rj.r.appspot.com/getchats/' +
          miembroActual!.id.toString()));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Chat.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load chats');
  }
}

Future<List<dynamic>> fetchNamesPersonDestino(int idPersonDestino) async {
  final response = await http.get(Uri.parse(
      'https://backendapi-398117.rj.r.appspot.com/getnamespersondestino/' +
          idPersonDestino.toString()));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse;
  } else {
    throw Exception('Failed to load chats');
  }
}