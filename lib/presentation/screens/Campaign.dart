import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:admin/Implementation/CampaignImplementation.dart';
import 'package:admin/Implementation/ChatImp.dart';
import 'package:admin/Implementation/ConversationImp.dart';
import 'package:admin/Implementation/TokensImp.dart';
import 'package:admin/Models/ChatModel.dart';
import 'package:admin/Models/ConversationModel.dart';
import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/List_members.dart';
import 'package:admin/presentation/screens/Login.dart';
import 'package:admin/presentation/screens/ProfilePage.dart';
import 'package:admin/presentation/screens/RegisterBoss.dart';
import 'package:admin/presentation/screens/ChatPage.dart';
import 'package:admin/presentation/screens/Conversations.dart';
import 'package:admin/presentation/screens/RegisterCampaign.dart';
import 'package:admin/presentation/screens/RegisterCardholders.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:admin/Models/CampaignModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

int estadoPerfil = 0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CampaignProvider(),
      child: MaterialApp(
        title: 'Campañas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CampaignPage(),
      ),
    );
  }
}

class CampaignProvider extends ChangeNotifier {
  List<Campaign> campaigns1 = campaigns;

  CampaignProvider() {
    //loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    //campaigns1 = await fetchCampaigns();

    notifyListeners();
  }

  void searchCampaign(String query) async {
    //campaigns1 = await fetchCampaigns();

    campaigns1 = campaigns
        .where((campaign) =>
            campaign.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();

    notifyListeners();
  }
}

class CampaignPage extends StatefulWidget {
  @override
  _CampaignStateState createState() => _CampaignStateState();
}

class _CampaignStateState extends State<CampaignPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchField = Padding(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        style: TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
        decoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(color: Color.fromARGB(255, 92, 142, 203)),
          prefixIcon:
              Icon(Icons.search, color: Color.fromARGB(255, 92, 142, 203)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Color.fromARGB(255, 92, 142, 203)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Color.fromARGB(255, 92, 142, 203)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Color.fromARGB(255, 92, 142, 203)),
          ),
        ),
        onChanged: (value) {
          context.read<CampaignProvider>().searchCampaign(value);
        },
      ),
    );

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 92, 142, 203),
        title: Text('Campañas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(77, 101, 150, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Text(
                              miembroActual!.names,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              miembroActual!.correo,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(Icons.campaign),
              title: Text('Registrar Campaña'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterCampaignPage(
                            initialData: Campaign(
                                id: 0,
                                nombre: "",
                                descripcion: "",
                                categoria: "",
                                dateStart: DateTime.now(),
                                dateEnd: DateTime.now(),
                                userId: 0),
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt),
              title: Text('Registrar Usuario'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterBossPage(
                            isUpdate: false,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Mensaje'),
              onTap: () async {
                if (miembroActual!.role == 'Cliente') {
                  Chat chatCliente = Chat(
                      idChats: 0,
                      idPerson: null,
                      idPersonDestino: miembroActual!.id,
                      fechaActualizacion: DateTime.now());
                  int lastId = 0;
                  List<Chat> filteredList = [];
                  await fetchChatsClient().then((value) => {
                        filteredList = value
                            .where((element) =>
                                element.idPersonDestino == miembroActual!.id)
                            .toList(),
                        if (filteredList.isEmpty)
                          {
                            registerNewChat(chatCliente).then((value) => {
                                  getLastIdChat().then((value) => {
                                        lastId = value,
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                    idChat: lastId,
                                                    nombreChat: 'Soporte',
                                                    idPersonDestino: 0,
                                                  )),
                                        )
                                      })
                                })
                          }
                        else
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                        idChat: filteredList[0].idChats,
                                        nombreChat: 'Soporte',
                                        idPersonDestino: 0,
                                      )),
                            )
                          }
                      });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreenState()),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Perfil'),
              onTap: () {
                estadoPerfil = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(member: miembroActual)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree),
              title: Text('Cuentas'),
              onTap: () {
                estadoPerfil = 1;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListMembersScreen()),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar Sesión'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('miembroLocal', 0);
                  tokenClean();
                  chats.clear();
                  namesChats.clear();
                  miembroActual = null;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Consumer<CampaignProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              searchField,
              Expanded(
                child: ListView.builder(
                  itemCount: provider.campaigns1.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Color.fromARGB(
                              255, 92, 142, 203), // Color del borde
                          width: 2.0, // Ancho del borde
                        ),
                      ),
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text(
                          provider.campaigns1[index].nombre,
                          style: TextStyle(
                            color: Color(0xFF4D6596),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          provider.campaigns1[index].descripcion,
                          style: TextStyle(color: Color(0xFF4D6596)),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterCampaignPage(
                                initialData: provider.campaigns1[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterCampaignPage(
                      initialData: Campaign(
                          id: 0,
                          nombre: "",
                          descripcion: "",
                          categoria: "",
                          dateStart: DateTime.now(),
                          dateEnd: DateTime.now(),
                          userId: 0),
                    )),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF4C6596),
      ),
    );
  }
}
