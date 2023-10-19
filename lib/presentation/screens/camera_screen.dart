import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final CameraController cameraController;

  CameraScreen(this.cameraController);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de la cámara
    widget.cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Libera los recursos de la cámara al salir de la pantalla
    widget.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cameraController.value.isInitialized) {
      return Container(); // Muestra un contenedor vacío si la cámara no está inicializada
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cámara'),
      ),
      body: AspectRatio(
        aspectRatio: widget.cameraController.value.aspectRatio,
        child: CameraPreview(
            widget.cameraController), // Muestra la vista previa de la cámara
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.cameraController.value.isTakingPicture) {
            return;
          }

          try {
            final image = await widget.cameraController.takePicture();
            Navigator.of(context)
                .pop(image.path); // Devuelve la ruta de la imagen capturada
          } catch (e) {
            print('Error al capturar la imagen: $e');
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
