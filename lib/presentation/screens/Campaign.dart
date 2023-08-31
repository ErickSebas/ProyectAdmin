import 'package:admin/presentation/screens/Accounts.dart';
import 'package:admin/presentation/screens/MyProfile.dart';
import 'package:admin/presentation/screens/RegisterBoss.dart';
import 'package:admin/presentation/screens/RegisterCampaign.dart';
import 'package:admin/presentation/screens/RegisterCardholders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  List<String> _campaigns = ["Campaña 1", "Campaña 2", "Campaña 3"]; 
  List<String> get campaigns => _campaigns;

  void searchCampaign(String query) {
    _campaigns = ["Campaña 1", "Campaña 2", "Campaña 3"]
        .where((campaign) => campaign.contains(query))
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
                        backgroundImage: AssetImage('assets/perritoProfile.png'), 
                        radius: 30,  
                      ),
                      SizedBox(height: 10),  
                      Column(
                        children: [
                          Text(
                            'Galaxixs1803',  
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5), 
                          Text(
                            'galaxixsum@@example.com',  
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
              ) 
            ),
            ListTile(
              leading: Icon(Icons.campaign),
              title: Text('Registrar Campaña'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterCampaignPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt),
              title: Text('Registrar Jefe de Brigada'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterBossPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Registrar Carnetizadores'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterCardholdersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Mensaje'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterCampaignPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree),
              title: Text('Cuentas'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar Sesión'),
                onTap: () {
                  // 
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
                  itemCount: provider.campaigns.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),  
                      ),
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text(
                          provider.campaigns[index],
                          style: TextStyle(color: Color(0xFF4D6596), fontWeight: FontWeight.bold), 
                        ),
                        subtitle: Text(
                          "provider.campaigns[index].description",
                          style: TextStyle(color: Color(0xFF4D6596)), 
                        ),
                        onTap: () {
                          //Mostrar_Campania(campania);
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
    );
  }
}


