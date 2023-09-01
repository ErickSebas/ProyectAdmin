class Member {

  final String name;

  final DateTime datebirthday;

  final int id;

  final String role;

  final String contrasena; // Nuevo atributo

  final String correo;

  final int telefono;

  final String carnet;

  final double longitud;

  final double latitud; // Nuevo atributo

  Member(

      {required this.name,

      required this.datebirthday,

      required this.id,

      required this.role,

      required this.contrasena, // Nuevo atributo

      required this.correo, // Nuevo atributo

      required this.telefono,

      required this.carnet,

      required this.latitud,

      required this.longitud});

}

 

// Lista de miembros (puedes mantenerla aquí o cargarla desde una fuente de datos externa)

final List<Member> members = [

  Member(

      name: "Marco",

      datebirthday: DateTime.now(),

      id: 1,

      role: "Administrador",

      contrasena: "12345",

      correo: "marco@gmail.com",

      telefono: 7549598,

      carnet: "2hf742h3",

      latitud: 1,

      longitud: 2),

  Member(

      name: "pepe",

      datebirthday: DateTime.now(),

      id: 6,

      role: "Administrador",

      contrasena: "12345",

      correo: "pepe@gmail.com",

      telefono: 1111111,

      carnet: "11d3fwe",

      latitud: 1,

      longitud: 2),

  Member(

      name: "Ana",

      datebirthday: DateTime.now(),

      id: 2,

      role: "User",

      contrasena: "12345",

      correo: "ana@gmail.com",

      telefono: 45354326,

      carnet: "4grafre",

      latitud: 1,

      longitud: 2),

  Member(

      name: "Carlos",

      datebirthday: DateTime.now(),

      id: 3,

      role: "Jefes",

      contrasena: "12345",

      correo: "carlos@gmail.com",

      telefono: 543543,

      carnet: "f4qfrwg5ew",

      latitud: 1,

      longitud: 2),

  Member(

      name: "Laura",

      datebirthday: DateTime.now(),

      id: 4,

      role: "Carnetizador",

      contrasena: "12345",

      correo: "laura@gmail.com",

      telefono: 754956432543298,

      carnet: "4f242fsf",

      latitud: 1,

      longitud: 2),

  Member(

      name: "Sara",

      datebirthday: DateTime.now(),

      id: 5,

      role: "Clientes",

      contrasena: "12345",

      correo: "sara@gmail.com",

      telefono: 6432541,

      carnet: "f42f42fes",

      latitud: 1,

      longitud: 2),

  // Agrega más miembros aquí

];

 