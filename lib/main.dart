import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'dart:convert';

import 'dart:convert';
import 'package:http/http.dart' as http;




void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<String>> data = [];

void _importExcel() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls', 'kml'],
  );

  if (result != null) {
    var path = result.files.single.path;

    if (path != null && File(path).existsSync()) {
      var fileBytes = File(path).readAsBytesSync();

      if (path.endsWith('.kml')) {
        var xmlDocument = XmlDocument.parse(const Utf8Decoder().convert(fileBytes));
        var placemarks = xmlDocument.findAllElements('Placemark');
        
        for (var placemark in placemarks) {
          //print(placemark.childElements.last);
          var lookAtElement = placemark.childElements.last.findElements('coordinates');

          var nameElement = placemark.findElements('name');
          String name = nameElement.isNotEmpty ? nameElement.first.text : '';
          
          String longitude;
          String latitude;
          for (var coordinatesElement in lookAtElement) {
            // Obtiene el contenido de texto de la etiqueta <coordinates>
            String coordinatesText = coordinatesElement.text;

            // Divide el texto por las comas
            List<String> splitCoordinates = coordinatesText.split(',');

            if (splitCoordinates.length >= 2) {
              longitude = splitCoordinates[0];
              latitude = splitCoordinates[1];
              data.add([name, latitude, longitude]);
            } 
          }
          
          //lookAtElement

          //print([name, long, lat]);
          
        }
        sendListToAPI(data);
        data.clear();
        print("//datos"+data.toString());

      } else {
        var excel = Excel.decodeBytes(fileBytes);
        for (var table in excel.tables.values) {
          for (var row in table.rows) {
            List<String> rowData = [];
            for (var cell in row) {
              rowData.add(cell?.value.toString() ?? "");
            }
            data.add(rowData);
            //print(rowData);
          }
        }
        sendListToAPI(data);
        
      }

      //post Backend
      

    }

    setState(() {});
  }
}

//Mysql
Future sendListToAPI(List<List<String>> myList) async {
  final String url = 'http://10.0.2.2:3000/data/add';
  final http.Client client = http.Client();

  try {
    final http.Response response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'data': myList, }),
    );
    if (response.statusCode == 200) {
      print('Data sent successfully!');
    } else {
      print('Error sending data: ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  } finally {
    client.close();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0, toolbarHeight: 10,),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _importExcel,
            child: const Text('Importar Excel'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data[index].join(', ')), 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
