import 'package:flutter/material.dart';

class Member {
  final String name;
  final DateTime date;
  final int id;
  final String role;

  Member({
    required this.name,
    required this.date,
    required this.id,
    required this.role,
  });
}

class ListMembersScreen extends StatelessWidget {
  final List<Member> members = [
    Member(name: "Marco", date: DateTime.now(), id: 1, role: "Admin"),
    Member(name: "Ana", date: DateTime.now(), id: 2, role: "User"),
    // Agrega más miembros aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text('Cuentas',
            style: TextStyle(
              color: Colors.white,
            )),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF4D6596),
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        Text(
                            "${member.date.day}/${member.date.month}/${member.date.year}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text("ID: ${member.id}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Rol: ${member.role}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para eliminar el miembro
                        },
                        child: Text("Eliminar"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ListMembersScreen()));
}
