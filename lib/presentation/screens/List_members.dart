import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/presentation/screens/ProfilePage.dart';
import 'package:provider/provider.dart';

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
  String selectedRole = esCarnetizador?"Jefe de Brigada": "Todos";
  String searchQuery = "";

  List<Member> filteredMembers() {
    if (selectedRole == "Todos") {
      return members.where((member) {
        final lowerCaseName = member.name.toLowerCase();
        final lowerCaseCarnet = member.carnet.toLowerCase();
        final lowerCaseQuery = searchQuery.toLowerCase();

        return lowerCaseName.contains(lowerCaseQuery) ||
            lowerCaseCarnet.contains(lowerCaseQuery);
      }).toList();
    } else {
      return members.where((member) {
        final lowerCaseName = member.name.toLowerCase();
        final lowerCaseCarnet = member.carnet.toLowerCase();
        final lowerCaseRole = member.role.toLowerCase();
        final lowerCaseQuery = searchQuery.toLowerCase();

        return (lowerCaseName.contains(lowerCaseQuery) ||
                lowerCaseCarnet.contains(lowerCaseQuery)) &&
            lowerCaseRole == selectedRole.toLowerCase();
      }).toList();
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
            onPressed: () {esCarnetizador? Navigator.pop(context):
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
                  onChanged: esCarnetizador ? null: (newValue) {
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
                              Text(
                                member.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${member.datebirthday.day}/${member.datebirthday.month}/${member.datebirthday.year}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Carnet: ${member.carnet}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Rol: ${member.role}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: esCarnetizador? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(member);
                                  },
                                  child: Text("Seleccionar"),
                                ),
                              ],
                            ) : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    
                                  },
                                  child: Text("Eliminar"),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
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
