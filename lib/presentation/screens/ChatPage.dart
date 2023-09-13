import 'package:admin/presentation/screens/Campaign.dart';
import 'package:admin/services/services_firebase.dart';
import 'package:flutter/material.dart';
import 'package:admin/Models/ChatModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Móvil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();

}

class _ChatPageState extends State<ChatPage> {
  
  late IO.Socket socket;
  
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    socket = IO.io('http://192.168.14.112:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('Conectado');
    });
    socket.onConnectError((data) => print("Error de conexión: $data"));
    socket.onError((data) => print("Error: $data"));


    socket.on('chat message', (data) {
      ChatMessage chat = ChatMessage(idPerson: miembroActual!.id, idPersonDestino: 2, mensaje: data);
      
      setState(() {
        messages.add(chat);
      });
    });
  }



  Future<void> sendMessage(int idPerson, int idPersonDestino, String mensaje) async {
  final url = 'http://192.168.14.112:3000/sendmessage';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'idPerson': idPerson,
      'idPersonDestino': idPersonDestino,
      'mensaje': mensaje,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al enviar el mensaje');
  }
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
        title: Text("Chat Soporte", style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
    body: Column(
      children: <Widget>[
       Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  crossAxisAlignment: messages[index].idPerson == miembroActual!.id
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    messages[index].idPerson != miembroActual!.id
                        ? Container()
                        : Container(),
                    Card(
                      color: messages[index].idPerson == miembroActual!.id
                          ? Colors.blue
                          : Colors.white,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: Text(
                          messages[index].mensaje,
                          style: TextStyle(
                            color: messages[index].idPerson == miembroActual!.id
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Color(0xFF4D6596)),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(color:  Color(0xFF4D6596).withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_controller.text.isNotEmpty) 
                  {   
                    sendMessage(miembroActual!.id, 2, _controller.text);
                    socket.emit('chat message', _controller.text);
                    _controller.clear();
                  }
                },
              )
            ],
          ),
        )
      ],
    ),
  );
}

}
