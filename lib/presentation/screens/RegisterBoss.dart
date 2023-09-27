import 'package:admin/Models/Cardholder.dart';
import 'package:admin/presentation/screens/List_members.dart';
import 'package:admin/services/services_firebase.dart';
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
  int? idRolSeleccionada;
  String nameJefe = "";
  int idJefe = 0;
  int idPerson = 0;
  Member? jefeDeCarnetizador;

  void initState() {
    super.initState();
    if (widget.userData?.id != null) {
      Cargar_Datos_Persona();
    }
  }

  void Cargar_Datos_Persona() async {
    idPerson = widget.userData!.id;
    nombre = widget.userData!.names;
    apellido = widget.userData!.lastnames!;
    datebirthday = widget.userData?.fechaNacimiento;
    dateCreation = widget.userData?.fechaCreacion;
    carnet = widget.userData!.carnet!;
    telefono = widget.userData!.telefono.toString();
    selectedRole = widget.userData!.role;

    latitude = widget.userData!.latitud.toString();
    longitude = widget.userData!.longitud.toString();
    email = widget.userData!.correo;
    if(esCarnetizador){
      jefeDeCarnetizador = await getCardByUser(widget.userData!.id);
      nameJefe = jefeDeCarnetizador!.names;
      idJefe = jefeDeCarnetizador!.id;
    }
    
    setState(() {});
  }

  Future<void> registerUser() async {
    final url =
        Uri.parse('http://181.188.191.35:3000/register');
    if (selectedRole == 'Administrador') {
      idRolSeleccionada = 1;
    } else if (selectedRole == 'Jefe de Brigada') {
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
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario')),
      );
    }
  }

  Future<void> updateUser() async {
    final url =
        Uri.parse('http://181.188.191.35:3000/update/'+idPerson.toString()); //
    if (selectedRole == 'Administrador') {
      idRolSeleccionada = 1;
    } else if (selectedRole == 'Jefe de Brigada') {
      idRolSeleccionada = 2;
    } else if (selectedRole == 'Carnetizador') {
      idRolSeleccionada = 3;
    } else {
      // Puedes manejar cualquier otro caso aquí, si es necesario.
    }
    final response = await http.put(
      url,
      body: jsonEncode({
        'id' : idPerson,
        'Nombres': nombre,
        'Apellidos': apellido,
        'FechaNacimiento': datebirthday.toIso8601String(),
        'Carnet': carnet,
        'Telefono': telefono,
        'IdRol': idRolSeleccionada,
        'Latitud': latitude,
        'Longitud': longitude,
        'Correo': email,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registro exitoso
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario')),
      );
    }

    if(miembroActual!.id==widget.userData!.id){
      miembroActual!.names= nombre;
      miembroActual!.lastnames= apellido;
      miembroActual!.fechaNacimiento= datebirthday;
      miembroActual!.carnet= carnet;
      miembroActual!.telefono= int.parse(telefono);
      miembroActual!.role= selectedRole!;
      miembroActual!.latitud= double.parse(latitude);
      miembroActual!.longitud= double.parse(longitude);
      miembroActual!.correo= email;
    }
  }

  Future<void> registerJefeCarnetizador() async {
    final url = Uri.parse(
        'http://181.188.191.35:3000/registerjefecarnetizador');

    final response = await http.post(
      url,
      body: jsonEncode({
        'idPerson': idPerson, //

        'idJefeCampaña': idJefe,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registro exitoso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario')),
      );
    }
  }

  Future<void> updateJefeCarnetizador() async {
    final url = Uri.parse(
        'http://181.188.191.35:3000/updatejefecarnetizador');

    final response = await http.put(
      url,
      body: jsonEncode({
        'idPerson': idPerson, //

        'idJefeCampaña': idJefe,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registro exitoso
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
              esCarnetizador = false;
              widget.isUpdate==false?
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => CampaignProvider(),
                    child: CampaignPage(),
                  ),
                ),
              ):Navigator.pop(context);
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
                  'Jefe de Brigada',
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
                            child:
                                Text(nameJefe == '' ? "Seleccionar" : nameJefe),
                            onPressed: () async {
                              esCarnetizador = true;

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListMembersScreen()),
                              );

                              if (result != null) {
                                jefeDeCarnetizador = result;
                                nameJefe = jefeDeCarnetizador!.names;
                                idJefe = jefeDeCarnetizador!.id;
                              }
                              setState(() {});
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
              widget.isUpdate?Container():
              _buildTextField(
                initialData: "",
                label: 'Contraseña',
                onChanged: (value) => password = value,
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  dateCreation = new DateTime.now();
                  status = 1;
                  if (esCarnetizador &&
                      _formKey.currentState!.validate() &&
                      latitude != '' &&
                      selectedRole != '' &&
                      datebirthday != null  &&
                      nameJefe != '') {

                      if(widget.isUpdate){

                        await updateUser();
                        await updateJefeCarnetizador();
                        Mostrar_Finalizado(context, "Actualización Completado");
                        
                      }else if(password != ""){
                        dateCreation = new DateTime.now();
                        status = 1;
                        await registerUser();
                        idPerson = await getNextIdPerson();
                        await registerJefeCarnetizador();
                        Mostrar_Finalizado(context, "Registro Completado");
                      }
                      esCarnetizador = false;
                      

                  } else {
                    if (esCarnetizador == false &&
                        _formKey.currentState!.validate() &&
                        latitude != '' &&
                        selectedRole != '' &&
                        datebirthday != null 
                        ) {
                      
                      if(widget.isUpdate){
                        await updateUser();
                        Mostrar_Finalizado(context, "Actualización Completado");
                      }else if(password != ""){
                        dateCreation = new DateTime.now();
                        status = 1;
                        await registerUser();
                        Mostrar_Finalizado(context, "Registro Completado");
                      }

                      esCarnetizador = false;
                      
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ingrese todos los campos')),
                      );
                    }
                  }
                },
                child: Text(widget.isUpdate?'Actualizar':'Registrar'),
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
