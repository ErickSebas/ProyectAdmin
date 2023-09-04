import 'package:admin/presentation/screens/ProfilePage.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';
  String _password = '';
  String _confirmPassword = '';

@override
  void initState(){
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
        backgroundColor: Color(0xFF4D6596),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(member: miembroActual)),
              );

            },
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF4D6596),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Código', labelStyle: TextStyle(
                          fontSize: 16,
                          
                          color: Colors.white),),
                onChanged: (value) => _code = value,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña',labelStyle: TextStyle(
                          fontSize: 16,
                          
                          color: Colors.white)),
                onChanged: (value) => _password = value,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirmar Contraseña',labelStyle: TextStyle(
                          fontSize: 16,
                          
                          color: Colors.white)),
                onChanged: (value) => _confirmPassword = value,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (value != _password) return 'Las contraseñas no coinciden';
                  return null;
                },
                obscureText: true,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        
                      }
                    },
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF1A2946),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(member: miembroActual)),
                      );
                    },
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ) 
    );
  }
}
