

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
  DateTime? datebirthday = DateTime.now();
  var telefono='';
  bool actualizar=false;
  var id =0;

  String? selectedRole;
    Map<String, String> roles = {
    '1': 'Jefe de brigada',
    '2': 'Carnetizador',
    '3': 'Administrador',
  };

  void initState(){
    super.initState();
    if(widget.initialData.name!=""){
      Cargar_Datos();
    }
  }

  void registerNewMember(Member newMember) {
    members.add(newMember);
  }

  void updateMemberById(int id, Member updatedMember) {
    int index =members.indexWhere((member) => member.id == id);
    if (index != -1) {  
      members[index].name = updatedMember.name;
      members[index].datebirthday = updatedMember.datebirthday;
      members[index].role = updatedMember.role;
      members[index].correo = updatedMember.correo;
      members[index].telefono = updatedMember.telefono;
      members[index].carnet = updatedMember.carnet;
      members[index].latitud = updatedMember.latitud;
      members[index].longitud = updatedMember.longitud;
    }
  }

  
  void Cargar_Datos(){
    id = widget.initialData.id;
    actualizar = true;
    nombre = widget.initialData.name;
    descripcion = widget.initialData.carnet;
    categoria = widget.initialData.contrasena;
    selectedRole = widget.initialData.role;
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
            initialValue: nombre,
            label: 'Nombre',
            onChanged: (value) => nombre = value,
            validator: (value) => value!.isEmpty ? 'El nombre no puede estar vacío.' : null,
          ),
          SizedBox(height: 10),
          Text("Fecha Nacimiento:", style: TextStyle(color: Colors.white)),
          _buildDateOfBirthField(
            initialDate: datebirthday,
            label: 'Fecha Nacimiento',
            onChanged: (value) => datebirthday = value,
          ),
          _buildTextField(
            initialValue: carnet,
            label: 'Carnet',
            onChanged: (value) => carnet = value,
            validator: (value) => value!.isEmpty ? 'El carnet no puede estar vacío.' : null,
          ),
          _buildTextField(
            initialValue: telefono,
            label: 'Teléfono',
            onChanged: (value) => telefono = value,
            validator: (value) => value!.isEmpty ? 'El Teléfono no puede estar vacía.' : null,
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            hint: Text('Rol', style: TextStyle(color: Colors.white)),
            value: selectedRole,
            dropdownColor: Colors.grey[850], 
            style: TextStyle(color: Colors.white),
            items: <String>['Jefe de brigada', 'Carnetizador', 'Administrador']
            .map((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedRole = newValue;
              });
            },
            
          ),
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
            child: Text(latitude + " " + longitude, style: TextStyle(color: Colors.white),
            ),
          ),

          _buildTextField(
            initialValue: email,
            label: 'Email',
            onChanged: (value) => email = value,
            validator: (value) => value!.isEmpty ? 'El email no puede estar vacío.' : null,
            keyboardType: TextInputType.emailAddress,
          ), actualizar?Container():
          _buildTextField(
            initialValue: password,
            label: 'Contraseña',
            onChanged: (value) => password = value,
            //validator: (value) => value!.isEmpty ? 'La contraseña no puede estar vacía.' : null,
            obscureText: true,
          ),
          
          SizedBox(height: 20),
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(actualizar&&_formKey.currentState!.validate()&&latitude!=""&&selectedRole!=""&&datebirthday!=""){
                        Member newMember = Member(name: nombre, datebirthday: datebirthday!, id: id, role: selectedRole!, contrasena: password, correo: email, telefono: int.parse(telefono), carnet: carnet, latitud: double.parse(latitude), longitud: double.parse(longitude));
                        updateMemberById(id, newMember);
                        if(miembroActual!.id==id){
                          miembroActual = newMember;
                        }
                        Mostrar_Finalizado(context, "Se ha actualizado con éxito");
                      }else if (password!=""&&_formKey.currentState!.validate()&& latitude!=""&&selectedRole!=""&&datebirthday!="") {
                      registerNewMember(Member(name: nombre, datebirthday: datebirthday!, id: members.last.id+1, role: selectedRole!, contrasena: password, correo: email, telefono: int.parse(telefono), carnet: carnet, latitud: double.parse(latitude), longitud: double.parse(longitude)));
                      

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
                      primary: Color(0xFF1A2946),
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

  Widget _buildDateOfBirthField({
  required String label,
  required Function(DateTime?) onChanged,
  DateTime? initialDate,
}) {
  return Column(
    children: [
      Container(
        width: double.infinity, // Esto hará que el botón ocupe todo el ancho disponible
        child: ElevatedButton(
          onPressed: () async {
            datebirthday = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (datebirthday != null) {
              onChanged(datebirthday);
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



  Widget _buildTextField({
  required String label,
  required Function(String) onChanged,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  required String initialValue,
}) {
  return Column(
    children: [
      TextFormField(
        enabled: actualizar&&label=="Contraseña" ? false: true,
        initialValue: initialValue,
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