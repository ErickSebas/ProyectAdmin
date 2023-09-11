import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/Models/Profile.dart';
import 'package:provider/provider.dart';
import 'Campaign.dart';
import 'LocationPicker.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterBossPage(
        isUpdate: false,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterBossPage extends StatefulWidget {
  final Member? userData;
  late final bool isUpdate;

  RegisterBossPage({required this.isUpdate, this.userData});
  @override
  _RegisterBossPageState createState() => _RegisterBossPageState();
}

class _RegisterBossPageState extends State<RegisterBossPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellido = '';
  var datebirthday;
  var dateCreation;
  String carnet = '';
  String telefono = '';
  String? selectedRole = 'Administrador';
  String latitude = '';
  String longitude = '';
  String email = '';
  String password = '';
  int status = 1;
  bool esCarnetizador = false;
  int? idRolSeleccionada;

  void initState() {
    super.initState();
    if (widget.userData?.id != "") {
      Cargar_Datos_Persona();
    }
  }

  void Cargar_Datos_Persona() async {
    nombre = widget.userData!.names;
    apellido = widget.userData!.lastnames!;
    datebirthday = widget.userData?.fechaNacimiento;
    dateCreation = widget.userData?.fechaCreacion;
    carnet = widget.userData!.carnet;
    telefono = widget.userData!.telefono.toString();
    if (idRolSeleccionada == 1) {
      selectedRole == 'Administrador';
    } else if (idRolSeleccionada == 2) {
      selectedRole == 'Jefe de brigada';
    } else if (idRolSeleccionada == 3) {
      selectedRole == 'Carnetizador';
    } else {
      // Puedes manejar cualquier otro caso aquí, si es necesario.
    }
    latitude = widget.userData!.latitud.toString();
    longitude = widget.userData!.longitud.toString();
    email = widget.userData!.correo;
    setState(() {});
  }

  void registerUser() async {
    final url =
        Uri.parse('https://backendapi-398117.rj.r.appspot.com/register');

    if (selectedRole == 'Administrador') {
      idRolSeleccionada = 1;
    } else if (selectedRole == 'Jefe de brigada') {
      idRolSeleccionada = 2;
    } else if (selectedRole == 'Carnetizador') {
      idRolSeleccionada = 3;
    } else {
      // Puedes manejar cualquier otro caso aquí, si es necesario.
    }
    final response = await http.post(
      url,
      body: jsonEncode({
        'Nombres': nombre,
        'Apellidos': apellido,
        'FechaNacimiento': datebirthday.toIso8601String(),
        'FechaCreacion': dateCreation.toIso8601String(),
        'Carnet': carnet,
        'Telefono': telefono,
        'IdRol': idRolSeleccionada,
        'Latitud': latitude,
        'Longitud': longitude,
        'Correo': email,
        'Password': password,
        'Status': status,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registro exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => CampaignProvider(),
            child: CampaignPage(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario')),
      );
    }
  }

  Future<void> Permisos() async {
    LocationPermission permiso;
    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return Future.error('Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isUpdate
        ? 'Actualizar Usuario'
        : 'Registrar Usuario'; // Título dinámico

    return Scaffold(
      backgroundColor: Color(0xFF4D6596),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text(title, style: TextStyle(color: Colors.white)),
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
                    child: CampaignPage(),
                  ),
                ),
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
                ),
              ),
              _buildTextField(
                initialData: nombre,
                label: 'Nombres',
                onChanged: (value) => nombre = value,
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío.' : null,
              ),
              _buildTextField(
                initialData: apellido,
                label: 'Apellidos',
                onChanged: (value) => apellido = value,
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío.' : null,
              ),
              SizedBox(height: 10),
              Text("Fecha Nacimiento:", style: TextStyle(color: Colors.white)),
              _buildDateOfBirthField(
                label: 'Fecha Nacimiento',
                onChanged: (value) => datebirthday = value,
              ),
              _buildTextField(
                initialData: carnet,
                label: 'Carnet',
                onChanged: (value) => carnet = value,
                validator: (value) =>
                    value!.isEmpty ? 'El carnet no puede estar vacío.' : null,
              ),
              _buildTextField(
                initialData: telefono,
                label: 'Teléfono',
                onChanged: (value) => telefono = value,
                validator: (value) =>
                    value!.isEmpty ? 'El Teléfono no puede estar vacía.' : null,
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                hint: Text('Rol', style: TextStyle(color: Colors.white)),
                value: selectedRole,
                dropdownColor: Colors.grey[850],
                style: TextStyle(color: Colors.white),
                items: <String>[
                  'Jefe de brigada',
                  'Carnetizador',
                  'Administrador'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedRole = newValue!;
                    if (newValue == "Carnetizador") {
                      esCarnetizador = true;
                    } else {
                      esCarnetizador = false;
                    }
                  });
                },
              ),
              esCarnetizador
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text("Seleccionar Jefe:",
                            style: TextStyle(color: Colors.white)),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text("Seleccionar"),
                            onPressed: () async {
                              // Agregar aquí la lógica para seleccionar un jefe
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF1A2946),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 10),
              Text("Dirección:", style: TextStyle(color: Colors.white)),
              ElevatedButton(
                child: Text("Selecciona una ubicación"),
                onPressed: () async {
                  await Permisos();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPicker(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      latitude = result.latitude.toString();
                      longitude = result.longitude.toString();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1A2946),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  latitude + " " + longitude,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              _buildTextField(
                initialData: email,
                label: 'Email',
                onChanged: (value) => email = value,
                validator: (value) =>
                    value!.isEmpty ? 'El email no puede estar vacío.' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                initialData: "",
                label: 'Contraseña',
                onChanged: (value) => password = value,
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (esCarnetizador) {
                    // Agregar aquí la lógica para seleccionar un jefe
                  } else {
                    if (_formKey.currentState!.validate() &&
                        latitude != '' &&
                        selectedRole != '' &&
                        datebirthday != null &&
                        password != "") {
                      // Llama a la función para registrar al usuario
                      dateCreation = new DateTime.now();
                      status = 1;
                      registerUser();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ingrese todos los campos')),
                      );
                    }
                  }
                },
                child: Text('Registrar'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1A2946),
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
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              datebirthday = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (datebirthday != null) {
                onChanged(datebirthday);
                setState(() {});
              }
            },
            child: Text(
              datebirthday != null
                  ? "${datebirthday.day}/${datebirthday.month}/${datebirthday.year}"
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

  Widget _buildTextField({
    required String initialData,
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      children: [
        TextFormField(
          initialValue: initialData,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
          ),
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
