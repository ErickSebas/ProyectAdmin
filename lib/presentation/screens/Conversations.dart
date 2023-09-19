import 'package:admin/Models/ConversationModel.dart';
import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/presentation/screens/ChatPage.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:admin/Models/ChatModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(Conversations());

class Conversations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Móvil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreenState(),
    );
  }
}

class ChatScreenState extends StatefulWidget {
  @override
  _ChatScreenStateState createState() => _ChatScreenStateState();
}

class _ChatScreenStateState extends State<ChatScreenState> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final emailController = TextEditingController();
  bool isLoading = true;


  @override
  void initState() {
    super.initState();

    if(namesChats.isEmpty){
      fetchNamesPersonDestino(miembroActual!.id).then((value) => {
        if(mounted){
          setState(() {
            namesChats = value;
          })
        }
        
      });
      fetchChats().then((value) => {
        isLoading = false,
        if(mounted){
          setState((){
            chats = value;
          })
        }
        
      });
    }else{
      isLoading=false;
    }
    
    _tabController = TabController(length: 2, vsync: this);
    //namesChats = await fetchNamesPersonDestino(miembroActual!.id);
    socket.on('chat message', (data) async {
      if (!mounted) return; 
      List<dynamic> namesChatsNew = await fetchNamesPersonDestino(miembroActual!.id);
      fetchChats().then((value) {
        if (mounted) { // Asegúrate de comprobar aquí también
          setState(() {
            chats = value;
          });
        }
      });

      if (mounted) {
        setState(() {
          namesChats = namesChatsNew;
        });
      }
    });

  }

  

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> addNewChat() async {
    //Registrar Nuevo Chat
    bool canUser = true;
    int idPersonNewChat=0;
    Chat newChat = Chat(idChats: 0, idPerson: 0, idPersonDestino: 0, fechaActualizacion: DateTime.now());
    await getIdPersonByEMail(emailController.text).then((value) => {
      idPersonNewChat = value,
      if(value==miembroActual!.id){
        Mostrar_Error(context, "No puede iniciar un chat con su correo"),
        canUser =false
      }else if(value==0){
        Mostrar_Error(context, "No se encontró el correo"),
        canUser = false
      },
      newChat = Chat(idChats: 0, idPerson: miembroActual!.id, idPersonDestino: idPersonNewChat, fechaActualizacion: DateTime.now()),
    });
    if(canUser){
      int newIdChat = 0;
      await registerNewChat(newChat);
      await getLastIdChat().then((value) => {
          newIdChat = value,
          setState(() {
            chats.add(Chat(idChats: newIdChat, idPerson: miembroActual!.id, idPersonDestino: idPersonNewChat, fechaActualizacion: DateTime.now()));
          })
      });
      
      
      List<dynamic> namesChatsNew = [];
      namesChats.clear();
      await fetchNamesPersonDestino(miembroActual!.id).then((value) => {
        if(mounted){
          namesChatsNew = value,
          setState(() {
            namesChats = namesChatsNew;
          })
        }
        
      });
    }
    //
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Color(0xFF4D6596),
  appBar: AppBar(
    backgroundColor: Color(0xFF4D6596),
    title: Text('Chats'),
    bottom: TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'Administración'),
        Tab(text: 'Soporte'),
      ],
    ),
    leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
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
  body: isLoading==false
      ? TabBarView(
          controller: _tabController,
          children: [
            ChatList(),
            EstadoList(),
          ],
        )
      : Center(
          child: CircularProgressIndicator(),
        ),
  floatingActionButton: FloatingActionButton(
     onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Iniciar nuevo chat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ingresa el email de la persona con la que quieres chatear:'),
                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Color(0xFF4D6596), fontSize: 16),
                  cursorColor: Color(0xFF4D6596),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF4D6596)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4D6596), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4D6596).withOpacity(0.5), width: 2.0),
                    ),
                    border: OutlineInputBorder(),
                    hintStyle: TextStyle(color: Color(0xFF4D6596).withOpacity(0.5)),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF4D6596)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Aceptar'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await addNewChat();
                  emailController.clear();
                },
              ),
            ],
          );
        },
      );
    },
    child: Icon(Icons.chat), // Icono de chat
    backgroundColor: Color.fromARGB(255, 0, 204, 255),
    foregroundColor: Colors.white,
    tooltip: 'Iniciar nuevo chat',
  ),
);

  }
}

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return chats[index].idPerson!=null? Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 5,
          child: InkWell(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(idChat: chats[index].idChats, nombreChat: namesChats[index]["Nombres"], idPersonDestino: 0,)),
              );
            },
            child: ListTile(
              title: Text(namesChats[index]["Nombres"]),
              subtitle: Text(namesChats[index]["mensaje"]),
              leading: CircleAvatar(
                child: Text('$index'),
                backgroundColor: Color(0xFF4D6596),
              ),
            ),
          ),
        ):Container();
      },
    );
  }
}

class EstadoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return chats[index].idPerson==null? Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 5,
          child: InkWell(
            onTap: () {
              print('idPersonDestino:'+chats[index].idPersonDestino.toString());
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(idChat: chats[index].idChats, nombreChat: namesChats[index]["Nombres"],idPersonDestino: chats[index].idPersonDestino)),
              );
            },
            child:  ListTile(
              title: Text(namesChats[index]["Nombres"]),
              subtitle: Text(namesChats[index]["mensaje"]),
              leading: CircleAvatar(
                child: Text('$index'),
                backgroundColor: Color(0xFF4D6596),
              ),
            ),
          ),
        ):Container();
      },
    );
  }
}