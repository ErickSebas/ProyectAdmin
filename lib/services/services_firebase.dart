import 'package:admin/Models/Ubicacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



FirebaseFirestore db = FirebaseFirestore.instance;




Future<void> insertData(List<Map<String, String>> mylist) async {
  // Obtenemos una referencia a la colección "ubicacion"
  CollectionReference ubicacionCollection = FirebaseFirestore.instance.collection('ubicacion');

  // Iteramos sobre cada elemento en la lista y lo insertamos como un documento
  for (var item in mylist) {
    await ubicacionCollection.add({
      'name': item['name'],
      'latitud': item['latitud'],
      'longitud': item['longitud'],
    });
  }
}

Future<void> dataToFirebase(List<Ubicacion> mylist) async {
  // Obtenemos una referencia a la colección "ubicacion"
  CollectionReference ubicacionCollection = FirebaseFirestore.instance.collection('ubicacion');
  int contador = 0;
  // Iteramos sobre cada elemento en la lista y lo insertamos como un documento
  for (var item in mylist.toList()) {
    contador ++;
    print(contador);
    await ubicacionCollection.add({
      'name': item.name,
      'latitude': item.latitude,
      'longitude': item.longitude,
    });
  }
}


