import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<String>> data = [];

  void _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var fileBytes = result.files.single.bytes!;
      var excel = Excel.decodeBytes(fileBytes);

      for (var table in excel.tables.values) {
        for (var row in table.rows) {
          List<String> rowData = [];
          for (var cell in row) {
            rowData.add(cell?.value.toString() ?? "");
          }
          data.add(rowData);
        }
      }

      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _importExcel,
            child: const Text('Importar Excel'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data[index].join(', ')), 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
