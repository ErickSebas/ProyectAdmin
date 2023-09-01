

import 'package:admin/Models/Profile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'Campaign.dart';
import 'LocationPicker.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class RegisterBossPage extends StatefulWidget {
  final Member initialData;

  RegisterBossPage({Key? key, required this.initialData}) : super(key: key);

   @override
  _RegisterBossPage createState() => _RegisterBossPage();
}

class _RegisterBossPage extends State<RegisterBossPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  var edad = '';
  String carnet = '';
  String rol = '';
  String latitude = '';
  String longitude = '';
  String email = '';
  String password = '';
  String? categoria;
  String kml = '';
  bool estaCargando = false;
  String? errorMessage;
  var telefono='';
  bool actualizar=false;
  var id =0;

  String? selectedRole;
    Map<String, String> roles = {
    '1': 'Jefe de brigada',
    '2': 'Carnetizador',
  };

  void initState(){
    super.initState();
    if(widget.initialData.name!=""){
      Cargar_Datos();
    }
  }

  
  void Cargar_Datos(){
    id = widget.initialData.id;
    actualizar = true;
    nombre = widget.initialData.name;
    descripcion = widget.initialData.carnet;
    categoria = widget.initialData.contrasena;
    rol = widget.initialData.role;
    email = widget.initialData.correo;
    latitude = widget.initialData.latitud.toString();
    telefono = widget.initialData.telefono.toString();
    carnet = widget.initialData.carnet;
    longitude = widget.initialData.longitud.toString();
  }

  Future<void> Permisos() async{
    LocationPermission permiso;
      permiso = await Geolocator.checkPermission();
      if(permiso == LocationPermission.denied){
        permiso = await Geolocator.requestPermission();
        if(permiso == LocationPermission.denied){
          return Future.error('error');
        }
    }
  }

    void updateUserById(int id, Member updatedUser) {
      int index = members.indexWhere((campaign) => campaign.id == id);
      if (index != -1) {  
        members[index] = updatedUser;
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Color(0xFF4D6596),
  appBar: AppBar(
    backgroundColor: Color(0xFF4D6596),
    title: Text(actualizar ? 'Actualizar Usuario':'Registrar Usuario', style: TextStyle(color: Colors.white)),
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
            child: Image.asset('assets/LogoNew.png', height: 100, width: 100,),  
          ),
          _buildTextField(
            label: 'Nombre',
            onChanged: (value) => nombre = value,
            validator: (value) => value!.isEmpty ? 'El nombre no puede estar vacío.' : null,
          ),
          _buildTextField(
            label: 'Edad',
            onChanged: (value) => edad = value,
            validator: (value) => value!.isEmpty ? 'La edad no puede estar vacía.' : null,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            label: 'Carnet',
            onChanged: (value) => carnet = value,
            validator: (value) => value!.isEmpty ? 'El carnet no puede estar vacío.' : null,
          ),
          _buildTextField(
            label: 'Teléfono',
            onChanged: (value) => telefono = value,
            validator: (value) => value!.isEmpty ? 'El Teléfono no puede estar vacía.' : null,
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            dropdownColor: Color(0xFF4D6596),
            value: selectedRole,
            decoration: InputDecoration(
              labelText: 'Rol',
              labelStyle: TextStyle(color: Colors.white), 
            ),
            items: roles.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value, style: TextStyle(color: Colors.white),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRole = newValue;
              });
            },
            validator: (value) => value == null ? 'El rol es obligatorio.' : null,
          ),


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
              primary: Color(0x1A2946),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(latitude + " " + longitude, style: TextStyle(color: Colors.white),
            ),
          ),

          _buildTextField(
            label: 'Email',
            onChanged: (value) => email = value,
            validator: (value) => value!.isEmpty ? 'El email no puede estar vacío.' : null,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            label: 'Contraseña',
            onChanged: (value) => password = value,
            validator: (value) => value!.isEmpty ? 'La contraseña no puede estar vacía.' : null,
            obscureText: true,
          ),
          
          SizedBox(height: 20),
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(actualizar&&_formKey.currentState!.validate()){
                        Member updatedMember = Member(name: nombre, datebirthday: DateTime.now(), id: id, role: roles[selectedRole]!, contrasena: password, correo: email, telefono: int.parse(telefono), carnet: carnet, latitud: double.parse(latitude), longitud: double.parse(longitude));
                        updateUserById(id, updatedMember);
                        Mostrar_Finalizado(context, "Se ha actualizado con éxito");
                      }else
                      if (_formKey.currentState!.validate()) {
                      bool res = addMember(Member(name: nombre, datebirthday: DateTime.now(), id: members.last.id+1, role: roles[selectedRole]!, contrasena: password, correo: email, telefono: int.parse(telefono), carnet: carnet, latitud: double.parse(latitude), longitud: double.parse(longitude)));
                      

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