import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _prediction = "Nenhuma predição";
  final ImagePicker _picker = ImagePicker();
  late ClassificationModel classificationModel;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Carregar o modelo PyTorch
  Future<void> _loadModel() async {
    try {
      classificationModel = await PytorchLite.loadClassificationModel(
        "assets/models/model_classification.pt",
        224,
        224,
        1000,
        labelPath: "assets/labels/label_classification_imageNet.txt",
      );
    } catch (e) {
      print("Erro ao carregar o modelo: $e");
    }
  }

  // Selecionar uma imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _runModel();
    }
  }

  // Rodar a inferência do modelo
  Future<void> _runModel() async {
    try {
      if (_image != null) {
        String prediction = await classificationModel.getImagePrediction(
          await _image!.readAsBytes(),
        );
        // Exibir o retorno da inferência
        print("Valor do retorno: $prediction");

        setState(() {
          _prediction = "Classe prevista: $prediction";
        });
      }
    } catch (e) {
      print("Erro na inferência: $e");
      setState(() {
        _prediction = "Erro ao rodar modelo";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Classificação de Objetos")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text("Nenhuma imagem selecionada")
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Selecionar Imagem"),
            ),
            const SizedBox(height: 20),
            Text(_prediction),
          ],
        ),
      ),
    );
  }
}
