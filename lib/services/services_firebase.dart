import 'dart:convert';
import 'dart:io';
import 'package:admin/Models/Ubication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;

// Método guardar Archivo JSON
Future<File> _saveJsonInStorage(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/ubications.json');
  return file.writeAsString(jsonData);
}

// Método subir arhivo JSON en Firebase Storage
Future<void> upJsonToFirebase(List<Ubication> mylist) async {
  String jsonUbication = jsonEncode(mylist.map((p) => p.toJson()).toList());
  File file = await _saveJsonInStorage(jsonUbication);
  Reference ref = storage.ref().child('ubications.json');
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
  var url = await taskSnapshot.ref.getDownloadURL();
  print("URL del archivo: $url");
}
