import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:admin/Models/Ubication.dart';


class HomeClient extends StatefulWidget {
  @override
  _HomeClientState createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  List<Ubication> data = [];
  bool isLoading = false;

  // Método para importar archivos a la App
  void _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kml'],
    );

    if (result != null) {
      var path = result.files.single.path;

      if (path != null && File(path).existsSync()) {
        var fileBytes = File(path).readAsBytesSync();

        if (path.endsWith('.kml')) {
          var xmlDocument =
              XmlDocument.parse(const Utf8Decoder().convert(fileBytes));
          var placemarks = xmlDocument.findAllElements('Placemark');

          for (var placemark in placemarks) {
            var lookAtElement =
                placemark.childElements.last.findElements('coordinates');

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
                data.add(Ubication(
                    name: name, latitude: latitude, longitude: longitude));
              }
            }
          }
          setState(() {
            isLoading = true;
          });
          await upJsonToFirebase(data, (double progressValue) {
              setState(() {
                  progress = progressValue;
              });
          });
          data.clear();
          setState(() {
              isLoading = false;
          });

          // Mostrar toast notificando que se ha finalizado
          Fluttertoast.showToast(
              msg: "Finalizado",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
        } 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMINISTRACIÓN'),
        backgroundColor: Color(0xFF86ABF9),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset("assets/icon.png"),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  top: 15,
                  right: 10.0,
                  bottom: 5.0,
                ),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : _importFile,
                child: const Text('Importar KML'),
                style: ElevatedButton.styleFrom(
                  
                  primary: Color.fromARGB(255, 93, 118, 173),  // color de fondo del botón
                  onPrimary: Colors.white,  // color del texto
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                  },
                ),
              ),
            ],
          ),
          if (isLoading)
           Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),  // Agrega padding a los costados
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 20.0, // Ajusta este valor según el grosor deseado para la barra
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${(progress! * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
