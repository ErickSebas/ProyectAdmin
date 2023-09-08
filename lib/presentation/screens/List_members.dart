import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListMembersScreen extends StatefulWidget {
  @override
  _ListMembersScreenState createState() => _ListMembersScreenState();
}

class _ListMembersScreenState extends State<ListMembersScreen> {
  final List<String> roles = [
    "Todos",
    "Administrador",
    "Jefe de Brigada",
    "Carnetizador",
    //"Clientes"
  ];
  String selectedRole = esCarnetizador ? "Jefe de Brigada" : "Todos";
  String searchQuery = "";

  Future<List<Member>> fetchMembers() async {
    final response =
        await http.get(Uri.parse('https://backendapi-398117.rj.r.appspot.com/allaccounts'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((memberData) => Member.fromJson(memberData)).toList();
    } else {
      throw Exception('Failed to load members');
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
              esCarnetizador
                  ? Navigator.pop(context)
                  : Navigator.pushReplacement(
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
      body: Container(
        color: Color(0xFF4D6596),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Theme(
                data: ThemeData(
                  canvasColor: Color(0xFF4D6596),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: esCarnetizador
                      ? null
                      : (newValue) {
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre o carnet',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Member>>(
              future: fetchMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final members = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: members?.length,
                      itemBuilder: (context, index) {
                        final member = members?[index];
                        // Resto del código para mostrar la lista de miembros
                      },
                    ),
                  );
                }
              },
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
