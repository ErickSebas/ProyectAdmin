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
      home: RegisterBossPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterBossPage extends StatefulWidget {
  @override
  _RegisterBossPageState createState() => _RegisterBossPageState();
}

class _RegisterBossPageState extends State<RegisterBossPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  var datebirthday;
  String carnet = '';
  String telefono = '';
  String? selectedRole = 'Administrador';
  String latitude = '';
  String longitude = '';
  String email = '';
  String password = '';
  bool esCarnetizador = false;

  void registerUser() async {
    final url =
        Uri.parse('https://backendapi-398117.rj.r.appspot.com/register');
    final response = await http.post(
      url,
      body: jsonEncode({
        'Nombres': nombre,
        'FechaNacimiento': datebirthday.toIso8601String(),
        'Carnet': carnet,
        'Telefono': telefono,
        'IdRol': selectedRole,
        'Latitud': latitude,
        'Longitud': longitude,
        'Correo': email,
        'Password': password,
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
    return Scaffold(
      backgroundColor: Color(0xFF4D6596),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text('Registrar Usuario', style: TextStyle(color: Colors.white)),
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
                label: 'Nombre',
                onChanged: (value) => nombre = value,
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
                label: 'Carnet',
                onChanged: (value) => carnet = value,
                validator: (value) =>
                    value!.isEmpty ? 'El carnet no puede estar vacío.' : null,
              ),
              _buildTextField(
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
                label: 'Email',
                onChanged: (value) => email = value,
                validator: (value) =>
                    value!.isEmpty ? 'El email no puede estar vacío.' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
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
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      children: [
        TextFormField(
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
