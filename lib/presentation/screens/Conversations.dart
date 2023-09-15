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
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{ //192.168.14.112
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('Conectado');
    });
    socket.onConnectError((data) => print("Error de conexión: $data"));
    socket.onError((data) => print("Error: $data"));

    //namesChats = await fetchNamesPersonDestino(miembroActual!.id);
    socket.on('chat message', (data) async {
      List<dynamic> namesChatsNew = await fetchNamesPersonDestino(miembroActual!.id);
      if (mounted) {
        setState(() {
          namesChats = namesChatsNew;
        });
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatList(),
          EstadoList(),
        ],
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
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 5,
          child: InkWell(
            onTap: () async {
              // Aquí puedes navegar a la página del chat
              messages = await fetchMessage(chats[index].idChats);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(idChat: chats[index].idChats, nombreChat: namesChats[index]["Nombres"],)),
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
        );
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
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 5,
          child: InkWell(
            onTap: () {
              // Aquí puedes navegar a la página del chat
              //Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => ChatPage(chatId: index)),
              //);
            },
            child: ListTile(
              title: Text('Chat $index'),
              subtitle: Text('Último mensaje del chat $index'),
              leading: CircleAvatar(
                child: Text('$index'),
                backgroundColor: Color(0xFF4D6596),
              ),
            ),
          ),
        );
      },
    );
  }
}