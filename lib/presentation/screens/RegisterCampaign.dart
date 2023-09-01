import 'package:admin/Models/CampaignModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'HomeClient.dart';
import 'package:admin/presentation/screens/Campaign.dart';

import 'package:admin/services/services_firebase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:admin/Models/Ubication.dart';


class RegisterCampaignPage extends StatefulWidget {
  final Campaign initialData;

  RegisterCampaignPage({Key? key, required this.initialData}) : super(key: key);

  @override
  _RegisterCampaignPageState createState() => _RegisterCampaignPageState();
}

class _RegisterCampaignPageState extends State<RegisterCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  String? categoria;
  String kml = '';
  List<EUbication> Ubicaciones = [];
  bool estaCargando = false;
  bool actualizar = false;
  String? errorMessage;
  var id;

  void initState(){
    super.initState();
    if(widget.initialData.nombre!=""){
      Cargar_Datos();
      
    }
  }

  void updateCampaignById(int id, Campaign updatedCampaign) {
  int index =campaigns.indexWhere((campaign) => campaign.id == id);
  if (index != -1) {  
    campaigns[index] = updatedCampaign;
  }
}


  void Cargar_Datos(){
    id = widget.initialData.id;
    actualizar = true;
    nombre = widget.initialData.nombre;
    descripcion = widget.initialData.descripcion;
    categoria = widget.initialData.categoria;
  }
  
   void Importar_Archivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kml'],
    );

    if (result != null) {
      var path = result.files.single.path;
      kml = result.files.single.name;
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
                Ubicaciones.add(EUbication(
                    name: name, latitude: latitude, longitude: longitude));
              }
            }
          }
        } 
      }
      setState(() {
        
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4D6596),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text(actualizar ? 'Actualizar Campaña' : 'Registrar Campaña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => CampaignProvider(), 
                  child: CampaignPage())),
                );
              },
            ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Image.asset('assets/LogoNew.png', height: 100, width: 100,),  // Ajusta la ruta y las dimensiones según lo necesites
              ),
              TextFormField(
                initialValue: nombre,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    nombre = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                initialValue: descripcion,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    descripcion = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción no puede estar vacío.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              DropdownButton<String>(
                hint: Text('Selecciona una categoría', style: TextStyle(color: Colors.white)),
                value: categoria,
                dropdownColor: Colors.grey[850], 
                style: TextStyle(color: Colors.white),
                items: <String>['Categoría 1', 'Categoría 2', 'Categoría 3']
                .map((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                    );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    categoria = newValue;
                  });
                },
                
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: estaCargando ? null : Importar_Archivo,
                child: const Text('Importar KML'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0x1A2946), 
                ),
              ),
               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kml, style: TextStyle(color: Colors.white)),
                  ],
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(actualizar&&_formKey.currentState!.validate()){
                        Campaign updatedCampaign = Campaign(id: id, nombre: nombre, descripcion: descripcion, categoria: categoria!);
                        updateCampaignById(id, updatedCampaign);
                        Mostrar_Finalizado(context, "Se ha actualizado con éxito");
                      }else if (_formKey.currentState!.validate()&&categoria!=null&&kml!='') {
                        //Registrar
                      setState(() {
                        estaCargando = true;
                      });
                      await Subir_Json_Firebase(Ubicaciones, (double valorProceso) {
                          setState(() {
                              proceso = valorProceso;
                          });
                      });
                      Ubicaciones.clear();
                      setState(() {
                          estaCargando = false;
                      });

                      Fluttertoast.showToast(
                          msg: "Finalizado",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                        Mostrar_Finalizado(context, "Se ha registrado con éxito");
                      } else {
                        Mostrar_Error(context, "Ingrese todos los campos");
                      }
                    },
                    child: Text(actualizar ? 'Actualizar' : 'Registrar'),

                    style: ElevatedButton.styleFrom(
                      primary: Color(0x1A2946),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(create: (context) => CampaignProvider(), 
                        child: CampaignPage())),
                      );
                    },
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                ],
              ),
              if (estaCargando)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),  // Agrega padding a los costados
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0, // Ajusta este valor según el grosor deseado para la barra
                        child: LinearProgressIndicator(
                          value: proceso,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('${(proceso! * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
      ),
      
    );
  }
}
