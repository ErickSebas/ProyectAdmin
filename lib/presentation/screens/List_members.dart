import 'package:admin/Models/Profile.dart';

import 'package:admin/presentation/screens/Campaign.dart';

import 'package:admin/presentation/screens/ProfilePage.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

 

class ListMembersScreen extends StatefulWidget {

  @override

  _ListMembersScreenState createState() => _ListMembersScreenState();

}

 

class _ListMembersScreenState extends State<ListMembersScreen> {

  // Define una lista de roles disponibles

  final List<String> roles = [

    "Todos",

    "Administrador",

    "Jefes",

    "Carnetizador",

    "Clientes"

  ];

 

  // Define el valor seleccionado inicial y el valor seleccionado actual

  String selectedRole = "Todos";

 

  // Función para filtrar la lista según el rol seleccionado

  List<Member> filteredMembers() {

    if (selectedRole == "Todos") {

      return members; // Mostrar todos los miembros

    } else {

      return members.where((member) => member.role == selectedRole).toList();

    }

  }

 

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Color(0xFF4D6596),

        title: Text('Cuentas', style: TextStyle(color: Colors.white)),

        centerTitle: true,

        leading: Builder(

          builder: (context) => IconButton(

            icon: Icon(Icons.arrow_back),

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

      body: Container(

        color: Color(

            0xFF4D6596), // Cambiar el color de fondo detrás de todo el contenido

        child: Column(

          children: [

            // Agregar ComboBox (DropdownButtonFormField) antes de la lista

            Padding(

              padding: EdgeInsets.all(16.0),

              child: Theme(

                data: ThemeData(

                  canvasColor: Color(

                    0xFF4D6596, // Cambiar el color de fondo del menú desplegable

                  ),

                ),

                child: DropdownButtonFormField<String>(

                  value: selectedRole,

                  items: roles.map((role) {

                    return DropdownMenuItem<String>(

                      value: role,

                      child: Text(role, style: TextStyle(color: Colors.white)),

                    );

                  }).toList(),

                  onChanged: (newValue) {

                    setState(() {

                      selectedRole = newValue!;

                    });

                  },

                  decoration: InputDecoration(

                    filled: true,

                    fillColor: Color(0xFF4D6596),

                  ),

                ),

              ),

            ),

            Expanded(

              child: ListView.builder(

                itemCount: filteredMembers().length,

                itemBuilder: (context, index) {

                  final member = filteredMembers()[index];

                  return Container(

                    margin: EdgeInsets.all(16),

                    decoration: BoxDecoration(

                      gradient: LinearGradient(

                        colors: [Color(0xFF86ABF9), Color(0xFF4D6596)],

                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                      ),

                      borderRadius: BorderRadius.circular(16),

                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(16.0),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Row(

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [

                              Text(member.name,

                                  style: TextStyle(

                                      color: Colors.white,

                                      fontWeight: FontWeight.bold)),

                              Text(

                                "${member.datebirthday.day}/${member.datebirthday.month}/${member.datebirthday.year}",

                                style: TextStyle(color: Colors.white),

                              ),

                            ],

                          ),

                          SizedBox(height: 8),

                          Text("ID: ${member.id}",

                              style: TextStyle(

                                  color: Colors.white,

                                  fontWeight: FontWeight.bold)),

                          SizedBox(height: 8),

                          Text("Rol: ${member.role}",

                              style: TextStyle(

                                  color: Colors.white,

                                  fontWeight: FontWeight.bold)),

                          SizedBox(height: 16),

                          Align(

                            alignment: Alignment.bottomRight,

                            child: Row(

                              mainAxisAlignment: MainAxisAlignment.end,

                              children: [

                                ElevatedButton(

                                  onPressed: () {

                                    // Lógica para eliminar el miembro

                                  },

                                  child: Text("Eliminar"),

                                ),

                                SizedBox(width: 10), // Espacio entre botones

                                ElevatedButton(

                                  onPressed: () {

                                    // Navegar a la página de perfil y pasar el objeto Member correspondiente

                                    Navigator.push(

                                      context,

                                      MaterialPageRoute(

                                        builder: (context) =>

                                            ProfilePage(member: member),

                                      ),

                                    );

                                  },

                                  child: Text("Ver Perfil"),

                                ),

                              ],

                            ),

                          ),

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}

 

void main() {

  runApp(MaterialApp(home: ListMembersScreen()));

}