import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FoodClassifierPage extends StatefulWidget {
  @override
  _FoodClassifierPageState createState() => _FoodClassifierPageState();
}

class _FoodClassifierPageState extends State<FoodClassifierPage> {
  String _photoPath = "";
  String _predictedFood = "";
  Map<String, dynamic> _nutritionInfo = {};
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(15),
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text("Take a Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  _processPickedImage(pickedFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: Colors.green),
                title: Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  _processPickedImage(pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
        _isLoading = true;
        _errorMessage = "";
      });
      _classifyFood(File(pickedFile.path));
    }
  }




  Future<void> _classifyFood(File file) async {
    try {
      var uri = Uri.parse('http://10.0.2.2:5000/classify');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        setState(() {
          _predictedFood = jsonResponse['predicted_food'];
          _nutritionInfo = jsonResponse['nutrition'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _predictedFood = "";
          _nutritionInfo = {};
          _isLoading = false;
          _errorMessage = "Error: Could not load image";
        });
      }
    } catch (e) {
      setState(() {
        _predictedFood = "";
        _nutritionInfo = {};
        _isLoading = false;
        _errorMessage = "Error connecting to server";
      });
    }
  }

  void _clearResults() {
    setState(() {
      _photoPath = "";
      _predictedFood = "";
      _nutritionInfo = {};
      _errorMessage = "";
    });
  }

  Widget _buildResultWidget() {
    if (_isLoading) {
      return Column(
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
          SizedBox(height: 10),
          Text("Processing", style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      );
    } else if (_errorMessage.isNotEmpty) {
      return Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(_errorMessage, style: TextStyle(fontSize: 16, color: Colors.red)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text("Retry", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    } else if (_predictedFood.isNotEmpty) {
      return Column(
        children: [
          Text("Predicted Food: $_predictedFood", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 20),
          _nutritionInfo.isNotEmpty
              ? Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Estimated Nutrition Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                  _buildNutritionRow("Calories", "${_nutritionInfo['calories']} kcal", Icons.local_fire_department),
                  _buildNutritionRow("Proteins", "${_nutritionInfo['proteins']} g", Icons.fitness_center),
                  _buildNutritionRow("Carbohydrates", "${_nutritionInfo['carbohydrates']} g", Icons.energy_savings_leaf),
                  _buildNutritionRow("Fats", "${_nutritionInfo['fats']} g", Icons.opacity),
                ],
              ),
            ),
          )
              : Text("No nutrition info available", style: TextStyle(fontSize: 16, color: Colors.white)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _clearResults,
            child: Text("Clear Results", style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildNutritionRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend background behind app bar
      backgroundColor: Colors.transparent, // Make scaffold background transparent
      appBar: AppBar(
        title: Text("Nutrition Estimation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green, // Make app bar blue
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_photoPath.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: _clearResults,
            ),
        ],
      ),





      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center( // Center the entire column
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _photoPath.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(File(_photoPath), height: 200, fit: BoxFit.cover),
                )
                    : Column( // Centered image selector UI
                  children: [
                    Icon(Icons.image, size: 80, color: Colors.black26),
                    SizedBox(height: 10),
                    Text(
                      "Select an image ",
                      style: TextStyle(fontSize: 18, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Select Image", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildResultWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}