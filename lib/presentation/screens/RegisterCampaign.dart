import 'package:admin/Implementation/CampaignImplementation.dart';
import 'package:admin/Models/CampaignModel.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  DateTime? dateStart = DateTime.now();
  DateTime? dateEnd = DateTime.now();
  TextEditingController _textController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  void initState() {
    super.initState();
    if (widget.initialData.nombre != "") {
      Cargar_Datos();
    }
  }

  void Cargar_Datos() {
    id = widget.initialData.id;
    actualizar = true;
    nombre = widget.initialData.nombre;
    descripcion = widget.initialData.descripcion;
    categoria = widget.initialData.categoria;
    dateStart = widget.initialData.dateStart;
    dateEnd = widget.initialData.dateEnd;
  }

  double? dmsToDecimal(String dms) {
    if (dms == null || dms.isEmpty) {
      return null;
    }

    try {
      // Elimina las comillas innecesarias
      dms = dms.replaceAll("'", "").replaceAll("''", "").replaceAll("º", "").replaceAll(",", ".");

      // Divide el texto por los símbolos de grados, minutos y segundos
      List<String> parts = dms.split(RegExp(r'[^\d\.\-]+'));

      if (parts.isEmpty || parts[0].isEmpty) {
        return null;
      }

      double degrees = double.parse(parts[0]);
      double minutes = parts.length > 1 && parts[1].isNotEmpty ? double.parse(parts[1]) : 0;
      double seconds = parts.length > 2 && parts[2].isNotEmpty ? double.parse(parts[2]) : 0;

      double decimal = degrees + (minutes / 60) + (seconds / 3600);
      return decimal;
    } catch (e) {
      // Si ocurre un error, retorna null
      return null;
    }
  }


  void Importar_Archivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kml', 'csv', 'xlsx'],
    );

    if (result != null) {
      var path = result.files.single.path;
      var fileName = result.files.single.name;
      kml = result.files.single.name;
      if (path != null && File(path).existsSync()) {
        var fileBytes = File(path).readAsBytesSync();
        if (path.endsWith('.kml')) {
          _importarKml(fileBytes);
        } else if (path.endsWith('.csv')) {
          _importarCsv(fileBytes);
        } else if (path.endsWith('.xlsx')) {
          _importarExcel(fileBytes);
        }
      }
      setState(() {});
    }
  }

  void _importarKml(Uint8List fileBytes) {
    var xmlDocument = XmlDocument.parse(const Utf8Decoder().convert(fileBytes));
    var placemarks = xmlDocument.findAllElements('Placemark');
    for (var placemark in placemarks) {
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
        name = name.replaceAll('Ã³', 'ó');
        name = name.replaceAll('Vacunacion', 'Vacunación');
        name = name.replaceAll('vacunacion', 'Vacunación');
        name = name.replaceAll('VACUNACION', 'VACUNACIÓN');

        if (splitCoordinates.length >= 2) {
          longitude = splitCoordinates[0];
          latitude = splitCoordinates[1];
          if (longitude != null && latitude != null) {
            Ubicaciones.add(EUbication(
                name: name,
                latitude: latitude,
                longitude: longitude));
          }
        }
      }
    }
  }

  void _importarCsv(Uint8List fileBytes) {
    // Convierte los bytes a una cadena de texto
    String csvString = const Utf8Decoder().convert(fileBytes);
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);

    for (var row in rowsAsListOfValues) {
      if (row.length > 7) {  // Asegurarse de que la fila tenga suficientes columnas
        String name = row[2]; // Columna C
        String latitude = row[6].toString(); // Columna G
        String longitude = row[7].toString(); // Columna H

        // Convertir coordenadas a decimal
        double? latitudeDecimal = dmsToDecimal(latitude);
        double? longitudeDecimal = dmsToDecimal(longitude);

        if (latitudeDecimal != null && longitudeDecimal != null) {
          Ubicaciones.add(EUbication(
              name: name, latitude: latitudeDecimal.toString(), longitude: longitudeDecimal.toString()));
        }
      }
    }
  }

  void _importarExcel(Uint8List fileBytes) {
    var excel = exc.Excel.decodeBytes(fileBytes);
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null) {
        for (var row in sheet.rows) {
          if (row.length > 7) {  // Asegurarse de que la fila tenga suficientes columnas
            String name = row[2]?.value.toString() ?? ''; // Columna C
            String latitude = row[6]?.value.toString() ?? ''; // Columna G
            String longitude = row[7]?.value.toString() ?? ''; // Columna H

            // Convertir coordenadas a decimal
            double? latitudeDecimal = dmsToDecimal(latitude);
            double? longitudeDecimal = dmsToDecimal(longitude);

            if (latitudeDecimal != null && longitudeDecimal != null) {
              Ubicaciones.add(EUbication(
                  name: name, latitude: latitudeDecimal.toString(), longitude: longitudeDecimal.toString()));
            }
          }
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 92, 142, 203),
        title: Text(actualizar ? 'Actualizar Actividad' : 'Registrar Actividad',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.pop(context);
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
                child: Image.asset(
                  'assets/LogoNew.png',
                  height: 100,
                  width: 100,
                ), // Ajusta la ruta y las dimensiones según lo necesites
              ),
              Row(
                children: [
                  Icon(
                    Icons.holiday_village,
                    color: Color.fromARGB(255, 92, 142, 203),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: nombre,
                      style:
                          TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Actividad',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                        counterText: "${nombre.length}/50",
                        counterStyle: TextStyle(
                            color: Color.fromARGB(
                                255, 92, 142, 203)), // Estilo del contador
                        // Contador de caracteres
                      ),
                      maxLength: 50, // Límite máximo de caracteres
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 50) {
                            nombre = value.substring(0, 50);
                          }else{
                            nombre = value;
                          }
                        });
                      },
                      keyboardType:
                          TextInputType.multiline, // Teclado multilínea
                      maxLines: null, // Permite varias líneas de texto
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Color.fromARGB(255, 92, 142, 203),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: descripcion,
                      style:
                          TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                        counterText:
                            "${descripcion.length}/160", // Contador de caracteres
                        counterStyle:
                            TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                      ),
                      maxLength: 160, // Límite máximo de caracteres
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 160) {
                            descripcion = value.substring(0, 160);
                          } else {
                            descripcion = value;
                          }
                        });
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción no puede estar vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.list_alt, // Cambia esto al icono que prefieras
                    color: Color.fromARGB(255, 92, 142, 203),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Selecciona un Tipo de Actividad',
                          style: TextStyle(color: Color.fromARGB(255, 92, 142, 203)),),
                      value: categoria,
                      dropdownColor: Colors.grey[850],
                      style:
                          TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                      items: <String>['Vacuna', 'Carnetizacion', 'Control de Foco', 'Vacunación Continua', 'Rastrillaje']//MAS opciones?
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
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.date_range, // Cambia esto al icono que prefieras
                    color: Color.fromARGB(255, 92, 142, 203),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Fecha Inicio",
                    style: TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                  ),
                ],
              ),
              _buildDateOfBirthField(
                initialDate: dateStart,
                label: 'Fecha Inicio',
                onChanged: (value) => dateStart = value,
                fecha: dateStart,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.date_range, // Cambia esto al icono que prefieras
                    color: Color.fromARGB(255, 92, 142, 203),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Fecha Final",
                    style: TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
                  ),
                ],
              ),
              _buildDateOfBirthField(
                  initialDate: dateEnd,
                  label: 'Fecha Fin',
                  onChanged: (value) => dateEnd = value,
                  fecha: dateEnd),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: estaCargando ? null : Importar_Archivo,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Fondo blanco
                  onPrimary:
                      Color.fromARGB(255, 92, 142, 203), // Color del texto
                  elevation: 0, // Sin sombra
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5.0), // Borde redondeado
                    side: BorderSide(
                      color:
                          Color.fromARGB(255, 92, 142, 203), // Color del borde
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_upload,
                      color: Color.fromARGB(255, 92, 142, 203),
                    ),
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text(
                      'Importar Archivo',
                      style:
                          TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kml, style: TextStyle(color: Color.fromARGB(255, 92, 142, 203))),
                  ],
                ),
              ),),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (actualizar &&
                          _formKey.currentState!.validate() &&
                          (dateStart!.isBefore(dateEnd!) ||
                              dateStart!.isAtSameMomentAs(dateEnd!))) {

                        
                        await showLoadingDialog(context, () async {
                          Campaign updatedCampaign = Campaign(
                            id: id,
                            nombre: nombre,
                            descripcion: descripcion,
                            categoria: categoria!,
                            dateStart: dateStart!,
                            dateEnd: dateEnd!,
                            userId: miembroActual!.id);
                          await updateCampaignById(context, updatedCampaign); // Actualiza la campaña

                          if (kml != '') {
                            await Subir_Json_Firebase(id, Ubicaciones); // Sube el archivo KML
                            Ubicaciones.clear();
                          }


                        });
                        showSnackbar(context, "Se ha actualizado con éxito");
                        Navigator.pop(context, 1);
                        //Mostrar_Finalizado(
                           // context, "Se ha actualizado con éxito");
                      } else if (_formKey.currentState!.validate() &&
                          categoria != null &&
                          kml != '' &&
                          (dateStart!.isBefore(dateEnd!) ||
                              dateStart!.isAtSameMomentAs(dateEnd!))) {
                        //Registrar
                        await showLoadingDialog(context, () async{
                          Campaign newCampaign = Campaign(
                              id: 0,
                              nombre: nombre,
                              descripcion: descripcion,
                              categoria: categoria!,
                              dateStart: dateStart!,
                              dateEnd: dateEnd!,
                              userId: miembroActual!.id);
                          await registerNewCampaign(context, newCampaign);
                          int idNextCamp = await getNextIdCampana(context);
                          await Subir_Json_Firebase(idNextCamp, Ubicaciones);
                          Ubicaciones.clear();
                        });
                        showSnackbar(context, "Se ha registrado con éxito");
                        Navigator.pop(context, 1);

                      } else {
                        Mostrar_Error(context, "Ingrese todos los campos");
                      }
                    },
                    child: Text(actualizar ? 'Actualizar' : 'Registrar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 92, 142, 203),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if(actualizar){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Eliminar Campaña?'),
                            content: Icon(Icons.warning,
                                color: Color(0xFF1A2946), size: 50),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancelar',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).pop(0);
                                },
                              ),
                              TextButton(
                                child: Text('Eliminar',
                                    style: TextStyle(color: Color(0xFF1A2946))),
                                onPressed: () async {
                                  CampaignProvider().loadCampaigns();
                                  await deleteCampaignById(context, id, miembroActual!.id);
                                  await eliminarArchivoDeStorage(id);
                                  Mostrar_Finalizado(
                                      context, "Se ha Elminado con éxito");
                                  Navigator.of(context).pop(1);
                                },
                              ),
                            ],
                          );
                        },
                      );}else{
                        Navigator.of(context).pop(0);
                      }
                    },
                    child: Text(actualizar?'Eliminar':'Cancelar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF1A2946),
                    ),
                  ),
                ],
              ),
              if (estaCargando)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Agrega padding a los costados
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height:
                              20.0, // Ajusta este valor según el grosor deseado para la barra
                          child: LinearProgressIndicator(
                            value: proceso,
                            backgroundColor: Colors.grey[200],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
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

  Widget _buildDateOfBirthField({
    required String label,
    required Function(DateTime?) onChanged,
    DateTime? initialDate,
    DateTime? fecha,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco
            border: Border.all(
              color: Color.fromARGB(255, 92, 142, 203), // Color del borde
            ),
            borderRadius: BorderRadius.circular(5.0), // Borde redondeado
          ),
          child: ElevatedButton(
            onPressed: () async {
              fecha = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100), // Fecha futura permitida hasta el año 2100
              );

              if (fecha != null) {
                onChanged(fecha);
                setState(() {});
              }
            },
            child: Text(
              initialDate != null
                  ? "${initialDate.day}/${initialDate.month}/${initialDate.year}"
                  : label,
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent, // Fondo transparente
              elevation: 0, // Sin sombra
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

}
