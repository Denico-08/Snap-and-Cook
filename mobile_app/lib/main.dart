import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const SnapCookApp());
}

class SnapCookApp extends StatelessWidget {
  const SnapCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap & Cook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  bool _isLoading = false;
  List<dynamic> _recipes = [];
  List<dynamic> _ingredients = [];
  
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // ✅ IP ANDA SUDAH SAYA MASUKKAN DISINI:
  final String _apiUrl = 'http://192.168.1.3:8000/predict'; 

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _recipes = []; 
        _ingredients = [];
      });
    }
  }

  Future<void> _uploadAndPredict() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = _selectedImage!.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(_selectedImage!.path, filename: fileName),
      });

      print("Mengirim ke: $_apiUrl"); // Cek log ini nanti
      Response response = await _dio.post(_apiUrl, data: formData);
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        setState(() {
          _ingredients = response.data['detected_ingredients'];
          _recipes = response.data['recipes'];
        });
        
        if (_recipes.isEmpty) {
          _showMsg("Bahan terdeteksi ($_ingredients), tapi resep tidak ditemukan.");
        }
      } else {
        _showMsg("Gagal memproses gambar.");
      }

    } catch (e) {
      print("Error: $e");
      _showMsg("Gagal koneksi: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _recipes = [];
      _ingredients = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap & Cook AI 🍳'),
        backgroundColor: Colors.orange.shade100,
        actions: [
          IconButton(onPressed: _reset, icon: const Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                  image: _selectedImage != null 
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : null
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                          Text("Tap untuk ambil foto"),
                        ],
                      )
                    : null,
              ),
            ),
            
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedImage != null && _recipes.isEmpty)
              FilledButton.icon(
                onPressed: _uploadAndPredict,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text("Cari Resep!"),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(15)),
              ),

            if (_ingredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                "Bahan Terdeteksi: ${_ingredients.join(', ')}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Divider(),
            ],

            if (_recipes.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            recipe['image'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stack) => Container(height: 150, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text("Bahan kurang: ${recipe['missedIngredientCount']}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(ImageSource.camera),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera),
      ),
    );
  }
}