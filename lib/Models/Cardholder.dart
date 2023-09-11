import 'dart:convert';

import 'package:http/http.dart' as http;

class Carnetizador {
  late int id;

  late int id_Jefe_Brigada;

  Carnetizador({required this.id, required this.id_Jefe_Brigada});
}

final List<Carnetizador> cardholders = [
  Carnetizador(id: 3, id_Jefe_Brigada: 4),
  Carnetizador(id: 5, id_Jefe_Brigada: 4),
  Carnetizador(id: 6, id_Jefe_Brigada: 4),
];

Future<int> getNextIdPerson() async {
  final response = await http.get(Uri.parse(
      'https://backendapi-398117.rj.r.appspot.com/nextidperson')); //////
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['AUTO_INCREMENT']);
    var res = jsonResponse[0]['AUTO_INCREMENT'];
    return res;
  } else {
    throw Exception('Failed to load id');
  }
}
