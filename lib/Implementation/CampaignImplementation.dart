import 'dart:convert';

import 'package:admin/Models/CampaignModel.dart';
import 'package:http/http.dart' as http;


Future<List<Campaign>> fetchCampaigns() async {
  final response = await http
      .get(Uri.parse('http://181.188.191.35:3000/campanas'));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Campaign.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load campaigns');
  }
}

Future<int> getNextIdCampana() async {
  final response = await http.get(Uri.parse(
      'http://10.0.2.2:3000/nextidcampanas')); //////
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse[0]['AUTO_INCREMENT']);
    var res = jsonResponse[0]['AUTO_INCREMENT'];
    return res;
  } else {
    throw Exception('Failed to load id');
  }
}

Future<void> registerNewCampaign(Campaign newCampaign) async {
  // Convertir tu objeto Campaign a JSON.
  final campaignJson = json.encode({
//'idCampañas': newCampaign.id,
    'NombreCampaña': newCampaign.nombre,
    'Descripcion': newCampaign.descripcion,
    'Categoria': newCampaign.categoria,
    'FechaInicio': newCampaign.dateStart.toString(),
    'FechaFinal': newCampaign.dateEnd.toString(),
    'userId': newCampaign.userId
  });
  final response = await http.post(
    Uri.parse('http://181.188.191.35:3000/campanas'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: campaignJson,
  );
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(response);
  }
  campaigns.add(newCampaign);
}

Future<void> updateCampaignById(Campaign updatedCampaign) async {
  // Convertir tu objeto Campaign a JSON.
  var id = updatedCampaign.id;
  final campaignJson = json.encode({
    'idCampañas': updatedCampaign.id,
    'NombreCampaña': updatedCampaign.nombre,
    'Descripcion': updatedCampaign.descripcion,
    'Categoria': updatedCampaign.categoria,
    'FechaInicio': updatedCampaign.dateStart.toString(),
    'FechaFinal': updatedCampaign.dateEnd.toString(),
    'userId': updatedCampaign.userId
  });
  final response = await http.put(
    Uri.parse('http://181.188.191.35:3000/campanas/$id'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: campaignJson,
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(response);
  }
  // Actualizar el objeto Campaign en tu lista local.
  int index = campaigns.indexWhere((campaign) => campaign.id == id);
  if (index != -1) {
    campaigns[index] = updatedCampaign;
  }
}

Future<void> deleteCampaignById(int id, int userId) async {
  // Convertir tu objeto Campaign a JSON.
  final campaignJson = json.encode({'idCampañas': id, 'userId': userId});
  final response = await http.put(
    Uri.parse('http://181.188.191.35:3000/campanas/delete/$id'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: campaignJson,
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(response);
  }
  // Actualizar el objeto Campaign en tu lista local.
  int index = campaigns.indexWhere((campaign) => campaign.id == id);
  if (index != -1) {
    campaigns.removeAt(index);
  }
}