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
  List<String> _campaigns = ["Campaña 1", "Campaña 2", "Campaña 3"]; // Ejemplo de campañas
  List<String> get campaigns => _campaigns;

  void searchCampaign(String query) {
    // Aquí puedes implementar la lógica para filtrar las campañas
    // Por ahora solo mostraré las campañas que contienen la query
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/perritoProfile.png'), 
                    radius: 30,  
                  ),
                  SizedBox(height: 10),  
                  Column(
                    children: [
                      Text(
                        'Nombre de Usuario',  
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),  // Espaciado entre el nombre de usuario y el correo electrónico
                      Text(
                        'email@example.com',  
                        style: TextStyle(
                          color: Colors.white70,  // Color más claro para el correo electrónico
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.campaign),
              title: Text('Registrar Campaña'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt),
              title: Text('Registrar Jefe de Brigada'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Registrar Carnetizadores'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Mensaje'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Perfil'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree),
              title: Text('Cuentas'),
              onTap: () {

              },
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
                        borderRadius: BorderRadius.circular(15.0),  // Establece el borde circular aquí
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
                          // Acción al hacer clic en la campaña
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


