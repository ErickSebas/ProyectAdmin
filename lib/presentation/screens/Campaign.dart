import 'package:admin/Models/Profile.dart';
import 'package:admin/presentation/screens/Accounts.dart';
import 'package:admin/presentation/screens/List_members.dart';
import 'package:admin/presentation/screens/Login.dart';
import 'package:admin/presentation/screens/ProfilePage.dart';
import 'package:admin/presentation/screens/RegisterBoss.dart';
import 'package:admin/presentation/screens/RegisterCampaign.dart';
import 'package:admin/presentation/screens/RegisterCardholders.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/Models/CampaignModel.dart';

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
  //List<String> _campaigns = ["Campaña 1", "Campaña 2", "Campaña 3"];
  CampaignManager manager = CampaignManager();
  List<Campaign> campaigns1 = campaigns;

  void searchCampaign(String query) {
    campaigns1 = campaigns
        .where((campaign) =>
            campaign.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}

class CampaignPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchField = Padding(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        onChanged: (value) {
          context.read<CampaignProvider>().searchCampaign(value);
        },
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFF4D6596),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
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
                  color: Color(0xFF4D6596),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/perritoProfile.png'),
                          radius: 30,
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Text(
                              miembroActual!.name,
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
                                categoria: ""),
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
                          initialData: Member(
                              name: "",
                              datebirthday: DateTime.now(),
                              id: 0,
                              role: "",
                              contrasena: "",
                              correo: "",
                              telefono: 0,
                              carnet: "",
                              latitud: 0,
                              longitud: 0))),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Mensaje'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterCampaignPage(
                            initialData: Campaign(
                                id: 0,
                                nombre: "",
                                descripcion: "",
                                categoria: ""),
                          )),
                );
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
                onTap: () {
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
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text(
                          provider.campaigns1[index].nombre,
                          style: TextStyle(
                              color: Color(0xFF4D6596),
                              fontWeight: FontWeight.bold),
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
                                    )),
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
                          id: 0, nombre: "", descripcion: "", categoria: ""),
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
