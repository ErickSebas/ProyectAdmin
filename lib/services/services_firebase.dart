import 'dart:convert';
import 'dart:io';

import 'package:admin/Models/Ubicacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;

Future<void> insertData(List<Map<String, String>> mylist) async {
  // Obtenemos una referencia a la colección "ubicacion"
  CollectionReference ubicacionCollection =
      FirebaseFirestore.instance.collection('ubicacion');

  // Iteramos sobre cada elemento en la lista y lo insertamos como un documento
  for (var item in mylist) {
    await ubicacionCollection.add({
      'name': item['name'],
      'latitud': item['latitud'],
      'longitud': item['longitud'],
    });
  }
}

Future<File> guardarJsonEnArchivo(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/ubications.json');
  return file.writeAsString(jsonData);
}

Future<void> subirArchivoAFirebase(List<Ubicacion> mylist) async {
  String jsonUbicacion = jsonEncode(mylist.map((p) => p.toJson()).toList());
  File file = await guardarJsonEnArchivo(jsonUbicacion);
  Reference ref = storage.ref().child('ubications.json');
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
  var url = await taskSnapshot.ref.getDownloadURL();
  print("URL del archivo: $url");
}

Future<void> dataToFirebase(List<Ubicacion> mylist) async {
  // Obtenemos una referencia a la colección "ubicacion"
  CollectionReference ubicacionCollection =
      FirebaseFirestore.instance.collection('ubicacion');

  // Eliminamos todos los documentos existentes en la colección "ubicacion"
  QuerySnapshot existingDocuments = await ubicacionCollection.get();
  for (DocumentSnapshot document in existingDocuments.docs) {
    await document.reference.delete();
  }

  int contador = 0;
  // Iteramos sobre cada elemento en la lista y lo insertamos como un documento
  for (var item in mylist.toList()) {
    contador++;
    print(contador);
    await ubicacionCollection.add({
      'name': item.name,
      'latitude': item.latitude,
      'longitude': item.longitude,
    });
  }
}
