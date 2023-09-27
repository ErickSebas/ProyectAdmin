import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> getNextIdPerson() async {
  final response = await http.get(Uri.parse(
      'http://181.188.191.35:3000/nextidperson')); //////
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['AUTO_INCREMENT']);
    var res = jsonResponse[0]['AUTO_INCREMENT'];
    return res;
  } else {
    throw Exception('Failed to load id');
  }
}