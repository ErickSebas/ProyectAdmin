import 'package:admin/Implementation/CampaignImplementation.dart';
import 'package:admin/Models/CampaignModel.dart';
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
          print(placemarks);
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
              name = name.replaceAll('Ã³', 'ó');
              name = name.replaceAll('Vacunacion', 'Vacunación');
              name = name.replaceAll('vacunacion', 'Vacunación');
              name = name.replaceAll('VACUNACION', 'VACUNACIÓN');

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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4D6596),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text(actualizar ? 'Actualizar Campaña' : 'Registrar Campaña',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => CampaignProvider(),
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
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la campaña',
                        labelStyle: TextStyle(color: Colors.white),
                        counterText: "${_textController.text.length}/50",
                        counterStyle: TextStyle(
                            color: Colors.white), // Estilo del contador
                        // Contador de caracteres
                      ),
                      maxLength: 50, // Límite máximo de caracteres
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 50) {
                            _textController.text = value.substring(0, 50);
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
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: descripcion,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: Colors.white),
                        counterText:
                            "${descripcion.length}/160", // Contador de caracteres
                        counterStyle: TextStyle(color: Colors.white),
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
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Selecciona una categoría',
                          style: TextStyle(color: Colors.white)),
                      value: categoria,
                      dropdownColor: Colors.grey[850],
                      style: TextStyle(color: Colors.white),
                      items: <String>['Vacuna', 'Carnetizacion']
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
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Fecha Inicio",
                    style: TextStyle(color: Colors.white),
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
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Fecha Final",
                    style: TextStyle(color: Colors.white),
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
                  primary: Color(0xFF1A2946),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_upload,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text(
                      'Importar KML',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
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
                      if (actualizar &&
                          _formKey.currentState!.validate() &&
                          (dateStart!.isBefore(dateEnd!) ||
                              dateStart!.isAtSameMomentAs(dateEnd!))) {
                        Campaign updatedCampaign = Campaign(
                            id: id,
                            nombre: nombre,
                            descripcion: descripcion,
                            categoria: categoria!,
                            dateStart: dateStart!,
                            dateEnd: dateEnd!,
                            userId: miembroActual!.id);
                        updateCampaignById(updatedCampaign);

                        if (kml != '') {
                          //Actualizar Ubicaciones
                          setState(() {
                            estaCargando = true;
                          });

                          await Subir_Json_Firebase(id, Ubicaciones,
                              (double valorProceso) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Espere unos momentos....'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Center(
                                          child: SpinKitFadingCube(
                                            color: Colors.blue,
                                            size: 50.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            setState(() {
                              proceso = valorProceso;
                            });
                          });
                          Ubicaciones.clear();
                          setState(() {
                            estaCargando = false;
                          });
                        }

                        Mostrar_Finalizado(
                            context, "Se ha actualizado con éxito");
                      } else if (_formKey.currentState!.validate() &&
                          categoria != null &&
                          kml != '' &&
                          (dateStart!.isBefore(dateEnd!) ||
                              dateStart!.isAtSameMomentAs(dateEnd!))) {
                        //Registrar
                        Campaign newCampaign = Campaign(
                            id: 0,
                            nombre: nombre,
                            descripcion: descripcion,
                            categoria: categoria!,
                            dateStart: dateStart!,
                            dateEnd: dateEnd!,
                            userId: miembroActual!.id);
                        await registerNewCampaign(newCampaign);
                        int idNextCamp = await getNextIdCampana();
                        setState(() {
                          estaCargando = true;
                        });
                        await Subir_Json_Firebase(idNextCamp, Ubicaciones,
                            (double valorProceso) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Espere unos momentos....'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Center(
                                        child: SpinKitFadingCube(
                                          color: Colors.blue,
                                          size: 50.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
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
                            fontSize: 16.0);
                        Mostrar_Finalizado(
                            context, "Se ha registrado con éxito");
                      } else {
                        Mostrar_Error(context, "Ingrese todos los campos");
                      }
                    },
                    child: Text(actualizar ? 'Actualizar' : 'Registrar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF1A2946),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Eliminar chat?'),
                            content: Icon(Icons.warning,
                                color: Colors.red, size: 50),
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
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  deleteCampaignById(id, miembroActual!.id);
                                  await eliminarArchivoDeStorage(id);
                                  Mostrar_Finalizado(
                                      context, "Se ha Elminado con éxito");
                                  Navigator.of(context).pop(1);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
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
          child: ElevatedButton(
            onPressed: () async {
              fecha = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
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
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF1A2946),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
